# MAKE PAYMENT (`mpay`) — Investigation & Verification Matrix

**Status:** 🔬 **Investigation only — NOT implemented.** Current Flutter "payment" is a LOCAL DUMMY
(SQLite insert, no backend `mpay`). Money-critical — do not implement until the matrix + missing
evidence below are closed.
**Source of truth:** D:\Git-Repos\magikdigi + verified Android testing/backend investigation (done externally).

> No sensitive values stored. Test ONLY against a local/test server + disposable test customer; NEVER live.

## API contract (Android)
- SOAP method `makePayments` (`mpay`); wrapper element `paymentInfo`, `i:type="makePaymentsInfo"`;
  posted to `PAY_URL` (confirm same data server vs gateway).
- ⚠️ Android marshals float fields (`MarshalFloat`/`MarshalDouble`) — `amount` is a typed float; the
  Flutter text envelope must send a server-accepted numeric format.
- `payment_flag = 4` = online app payment.

## Request fields (`makePaymentsInfo`) — key
`altCustomerId` (= customer_id), `authToken`, `imei`, `amount` (float), `billingId`, `due_amount`,
`modeType` (cash/bank/card/upi), `chequeNo/bank/branch/chequeDate` (bank), `rrnNo/cardholderName/paynearpaymentdetails`
(card), `discount_applied`/`discount_penalty_flag`/`max_discount_percentage_allowed` (STB discount), `sendsms`,
`payment_flag`, `transaction_number`, `mobileNumber`, `latitude`/`longitude`,
`broadband_payment_amount`/`broadband_user_id`/`broadband_due`/`is_for_renewal` (broadband).

## Evidence status — VERIFIED vs ASSUMED
> Rule: only mark VERIFIED when backed by observed backend rows / captured request-response, not source code alone.

### ✅ VERIFIED (STB) — from `acc_payment_details` backend rows
An app payment (`payment_flag=4`) inserts one row into `acc_payment_details` with these columns:
`customer_id, dealer_id, employee_id, billing_id, paid_on, payment_mode, paid_amount,`
`receipt_no, payment_flag(=4), latitude, longitude, is_discount, discount_penalty_flag, adv_payment_flag`.
- **`receipt_no` is server-generated**, pattern `CR{dealer_id}/{seq}/{counter}` → never fabricate client-side.
- `master_transaction_no` is **empty** for app payments (populated for web/adjustment rows, `payment_flag=0`).
- `adv_payment_flag=1` when paying with no/over-due balance (recorded as an **advance**); else `0`.
- Response carries `statusCode`/`statusMessage` + the server `receiptNumber` (exact response field names still
  to be locked from a captured response).

### 🟡 ASSUMED / evidence not yet reviewed
| Item | Needed evidence |
|---|---|
| `acc_billing` balance reduction (STB) | before/after rows for the paid `billing_id` |
| Broadband payment | `broadband_payment_details` + `broadband_payment_staging` rows |
| STB + Broadband | combined rows across all tables |
| Discount | an `is_discount=1` row + `discount_logs` / `customer_discount_penalty` |
| `mpay` request/response XML | captured request + response (to build/parse) |

### Backend tables (mapping)
| Customer type | Tables | Status |
|---|---|---|
| STB | `acc_payment_details` (+ `acc_billing`) | acc_payment_details ✅ · acc_billing 🟡 (before/after still needed) |
| Broadband | `broadband_payment_staging` → `broadband_payment_details` | ✅ flow verified |
| STB + Broadband | all of the above | 🟡 (combined rows + discount not yet seen) |

## Round-2 VERIFIED evidence (DB + Android getPendingAmount log)

### Broadband payment is ASYNC via staging (third-party)
`broadband_payment_staging` (cols incl. `staging_status`, `tries`, `staging_retrying`, `failed_message`,
`api_response`, `due_from_bb`, `broadband_payment_id`) → row inserted on payment (`staging_status=1`),
then a process calls the **third-party broadband API**, then on success a `broadband_payment_details`
row is created with the server `receipt_no`. Implications:
- Broadband uses **`billing_id = 0`**; STB uses a real `billing_id`.
- Separate **`broadband_customer_id`** (+ linked `stb_customer_id`), `is_renewal`, `receipt_from=MobileApp`.
- Broadband **receipt format** `…BR/RCPT/{year-week}/{counter}` (vs STB `CR{dealer}/{seq}/{counter}`).
- Confirms **no broadband discount** + deferred settlement (don't assume immediate receipt for broadband).

### GPA response — full field set (verified)
`statusCode, statusMessage, customerName, mobileNumber, pendingAmount, billingId, discount_amount,`
`total_payment_after_discount, discount_start/end_date, penalty_amount, total_payment_after_penalty,`
`penalty_start/end_date, discount_penalty_flag, nickname, cable_pending_amount,`
`broadcaster_pending_amount, last_paid_amount, last_paid_date, payments_count, adjustment_count`.
- **`billingId` for `mpay` comes from THIS response** (resolves the earlier unknown).
- STB vs broadband split = **`cable_pending_amount`** vs **`broadcaster_pending_amount`**.
- ⚠️ Our Flutter `PendingAmountRepository` currently reads only `pendingAmount`. For `mpay` it must ALSO
  capture **`billingId`** (and likely `cable_pending_amount`/`broadcaster_pending_amount` for STB+BB).

### Android parsing bug to NOT replicate
Android does raw `Double.valueOf("anyType{}")` on empty gpa fields → `NumberFormatException`
(`CustomerMgmt_MakePayment_Fragment:2004/2011/2023/2047`). Flutter uses `tryParse ?? 0.0` — keep that.
Real ksoap2 envelope includes `id="o0" c:root="1"` + per-field `i:type`; our simplified envelope works
(server lenient) — no change needed.

### Still missing
- `mpay` **request + response XML** (STB and broadband) — to build/parse the payment.
- `acc_billing` before/after (STB balance reduction).
- Discount example: `is_discount=1` row + `discount_logs` / `customer_discount_penalty`.
- STB+Broadband combined rows.

## Payment Verification Matrix
| Aspect | STB | Broadband | STB + Broadband |
|---|---|---|---|
| Amount field | `amount` | `broadband_payment_amount` | both |
| Pending source | `gpa.pendingAmount` (cable) | `broadcaster_pending_amount`/`broadband_due` | both |
| Discount | ✅ supported | ❌ not supported (third-party) | ⚠️ UNVERIFIED |
| Tables | acc_payment_details, acc_billing | broadband_payment_details, broadband_payment_staging | all four |
| Settlement | immediate | likely staged/async | mixed |
| Receipt # | server-issued | server-issued (timing TBC) | server-issued |

## Remaining unknowns
1. **Discount (PRIMARY):** STB+Broadband combined behavior; server validation vs `max_discount_percentage_allowed`; `discount_penalty_flag` values.
2. Broadband **staging** = async? Balance/receipt immediate or deferred?
3. `modeType` exact strings + required fields per mode.
4. `billingId` source.
5. Idempotency / double-submit server behaviour.
6. `payment_flag` offline value.

## Missing evidence needed before implementing
- [ ] Captured real `mpay` **request** XML (lock fields + amount format).
- [ ] Captured real `mpay` **response** XML (lock `receiptNumber` + status field names).
- [ ] STB+Broadband **discount rule** (or decision to defer broadband+discount).

## Definition of Done (per the 9-step rule) — none checked yet
1. Android source ▢ 2. Contract (real req/resp) ▢ 3. Flutter impl (real mpay) ▢ 4. Analyze ▢
5. Manual UI ▢ 6. Android compare ▢ 7. Error handling (double-submit + network-fail) ▢
8. Docs ▢ 9. User approval ▢

## Money-safety rules (enforced before/while implementing)
- Test only on a local/test server + disposable customer + tiny amount.
- Never fabricate a receipt number — use the server's.
- Guard double-submit (the current local-dummy inserts on every submit — must not carry into `mpay`).
- Confirm `PAY_URL` is NOT `digi.kccl.tv` (live) in test builds.
