# CUSTOMER SEARCH (`sc`) — Migration Record

**Status:** ✅ **Complete — manually verified** (search returns results, visible in UI,
parsing correct, blank-field issue resolved, Android/Flutter behaviour compared, no crashes).
**Source of truth:** D:\Git-Repos\magikdigi.

> Sensitive values (URLs, credentials, tokens, IMEIs, dealer IDs, customer data) omitted.

## Purpose
Search the dealer's customers by a chosen criteria (Name, Alt Customer Id, Mobile, CRF, etc.)
and show matching customers, so the user can open a customer and proceed to payment.

## Android source files used
- `Fragments/SearchCustomer_Fragment_Newdesign.java` — UI, criteria→`searchType`, SOAP call, response parsing.
- `complexclasses/searchCustomerInfo.java` — request model (field order).
- `complexclasses/searchCustomerList.java` — response item model.
- `assets/configg.properties` — `sc=searchCustomer`.

## Request contract (SOAP `searchCustomer`)
- Endpoint: `login_serverUrl`; SOAPAction `NAMESPACE/searchCustomer`.
- Wrapper element `custInfo`, `i:type="searchCustomerInfo"`.
- Fields: `authToken`, `imei`, `searchType` (int), `searchValue` (String), `dealer_id` (int), `is_list` (0).

### searchType mapping (criteria → number)
Confirmed from Android input hints + manual test:
`Name=2`, `Alt Customer Id=1`, `Primary Mobile Number=3`, `Secondary Mobile Number=9`,
`CRF Number=5`, `NickName=8`. Alphanumeric set (`Lco Customer Id=4`, `Serial Number=6`,
`VC Number=7`) mapped from Android branches.

## Response contract
- `statusCode` (0 = ok, non-zero = no records/error), `statusMessage`.
- Repeated `searchCustomerList` items. **Real field names** (confirmed from a live response):
  `customer_id`, `alt_cust_id`, `name`, `customnumber`, `mobile_no`, `address`, `city`, `state`,
  `country`, `group_name`, `box_numbers`, `vc_numbers`, `crf`, `pending`, `bill_month`,
  `total_amount`, `alt_custom_number`, `last_paid_date`, `customer_type`, `latitude`, `longitude`,
  `online_customer`, `last_month_pending_amount`, `is_sync_bills`.

## Flutter files modified / created
- **New:** `lib/features/search/data/search_repository.dart` — SOAP `sc` call + parse `searchCustomerList` → `Customer`.
- **New helper:** `SoapClient.readAll(xml, tag)` — extracts EVERY repeated element (response has many items).
- **Modified:** `lib/features/search/search_provider.dart` — criteria→`searchType`, calls repository, loading/error/results state.
- Reuses: `soap_client.dart`, `session_service.dart`, `customer.dart`. UI screen `search_customer_screen.dart` unchanged (already reads the provider).

## Session / auth dependencies
- `authToken` and `dealer_id` come from `SessionService` (set at login). Empty session → server rejects.
- `imei` via `--dart-define=DEVICE_IMEI` (test stand-in; real `ANDROID_ID` later).

## Error handling behaviour
- `statusCode==0` → results shown.
- non-zero → results cleared, provider `_error` set to the server `statusMessage` (e.g. "No records found").
- network/parse exception → `_error = "Search failed. Please try again."`, logged via `ErrorHandlerService`.
- (Android shows AlertDialogs for these; Flutter currently surfaces them inline on the search screen.)

## UI behaviour
- Loading spinner while searching; results list on success; inline message on no-records/error.
- Results survive navigation (provider lives above MaterialApp).

## Verification steps (how to re-verify / debug)
1. Run; log in; open Search; pick a criteria; type a value; Search.
2. Confirm results appear and fields (number, mobile, address, amount) are populated.
3. If debugging: temporarily log the response in `SearchRepository.search` and check
   `statusCode` → (0 = parsing/UI issue · 1 = wrong searchType/value · 3 = network/session).
4. Compare result count + a customer's fields against the Android app for the same query.

## Known limitations
- `searchType` for Lco/Serial/VC (4/6/7) mapped from Android branches; re-verify if any returns wrong results.
- Error states are inline (Android uses popup dialogs) — parity item, not blocking.
- `nickname`/`area_name` are not in the `sc` response → left blank in the model.
