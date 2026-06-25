# CloudDigi / MagikDigi — Flutter Migration Plan

> **Status:** Reference document. Migration-first strategy for porting the existing
> Android (Java) production app to Flutter, **reusing the existing backend, APIs,
> database, and Flutter UI**.
> **Delivery target:** 29th (internal APK / TestFlight delivery).
> **Stack (fixed — do NOT change):** Provider · Navigator · Repository · Dio · SQLite.
> **Last updated:** 2026-06-23

---

## 0. Guiding principle (read first)

**The existing Android Java app is the SPECIFICATION, not inspiration.**
For anything touching **money, receipts, or sync**, Flutter must reproduce the Java
behaviour *exactly* — same rounding, string formatting, date formats, ESC/POS printer
bytes, and request payloads. We are **porting** logic, not redesigning it. When in doubt,
match the Java output character-for-character and diff before shipping.

### Hard constraints
- ❌ No Riverpod / Bloc / GoRouter / full Clean Architecture / massive refactor.
- ✅ Keep existing folder structure, Provider state, Navigator, SQLite cache.
- ✅ Add exactly ONE new layer: **networking + repository** (Dio).
- 🎯 Optimize for: production stability · fastest delivery · lowest risk · UI reuse.

---

## 1. Reuse vs Rebuild — decided

**REUSE.** ~95% of Flutter screens are kept as-is. Existing structure
(`lib/core` + `lib/features`) is sound. Android flavors are ~70% done. The entire job is
**the data layer** — today the app makes almost no business API calls (only location
tracking + Google Maps directions); everything else reads local SQLite.

---

## 2. Architecture to add (the only change)

```
Screen (reuse)  →  Provider/Controller (reuse)  →  Repository (NEW)
                                                     ├── ApiClient (NEW, Dio)
                                                     └── DatabaseHelper (reuse — offline cache)
```

- Repository = the ONLY thing providers talk to.
- Repository pattern: `call API → map JSON → cache to SQLite → return; on network fail → return cache`.
- **Big reuse win:** existing providers already read from `DatabaseHelper`. If the
  repository writes API data into the existing SQLite cache, providers + screens work
  almost unchanged.

### New folders
```
lib/core/network/
  api_client.dart          # single Dio instance, baseUrl from AppConfig
  api_endpoints.dart       # all path constants in one place
  api_exception.dart       # typed errors for the UI
  interceptors/
    auth_interceptor.dart      # attach token
    logging_interceptor.dart   # logger
lib/features/<feature>/data/
  <feature>_repository.dart
  dto/<x>_response.dart        # API-shaped models with fromJson
```

### Dio client must have
- `baseUrl` from `AppConfig.instance.baseUrl` (per flavor).
- Connect / receive timeouts (no infinite hangs).
- Auth interceptor: attach token (confirm Bearer vs custom header from Java).
- Error interceptor: map to `ApiException`; **401 → logout/redirect** centrally.
- Logging interceptor (`logger` package).

---

## 3. Known model & data risks

| Risk | Detail | Action |
|---|---|---|
| Models are SQLite-shaped | `customer.dart` / `payment.dart` have `fromMap`/`toMap` for DB columns, not API JSON | Add `fromJson` **separately**; do not overwrite `fromMap` |
| Money stored as String `₹0` | `Customer.pendingAmount` is `String` with currency prefix; `Payment.amount` is `double` | Map number→formatted string via `money_parser.dart`; match Java's formatter |
| Field-name mismatch | Backend JSON field names differ from model fields | Get ONE real JSON sample per endpoint and pin it before coding |

---

## 4. Migration phases (6 days + buffer)

| Phase | Work | Day |
|---|---|---|
| **P0 — Contract extraction** | From Java + API docs: base URL, auth scheme, exact request/response JSON, money/receipt formulas, ESC/POS commands. No code. | Day 1 (½) |
| **P1 — Network foundation** | Dio `ApiClient` + interceptors + `ApiException` + 3 Android flavor fixes. | Day 1 |
| **P2 — Core path port** | Login → Customer → Payment → Receipt → Printing. | Days 2–4 |
| **P3 — Stabilize + secondary + flavors/iOS** | Offline sync, Reports/Complaints if time, error states, finish flavors, iOS, release builds. | Days 5–6 + buffer |

### Day-by-day
| Day | Date | Outcome | Confidence |
|---|---|---|---|
| 1 | Jun 23 | Get real JSON samples. Build `ApiClient`+interceptors+`ApiException`. Fix 3 Android blockers. | ✅ |
| 2 | Jun 24 | `AuthRepository` + real login (replace demo `admin/123456`) + `AuthProvider`. Token attach / 401 verified. | ✅ |
| 3 | Jun 25 | `CustomerRepository` (`Customer.fromJson`) → SQLite cache → list/detail/search screens light up. | ✅ |
| 4 | Jun 26 | `PaymentRepository` + `ReceiptRepository`: create payment, history, receipt; Bluetooth print on real data; offline-queue tested. | ✅ tight |
| 5 | Jun 27 | Error/retry states on every core screen + crash reporting verified. Build & smoke-test all 4 Android artifacts. | ✅ |
| 6 | Jun 28 | iOS flavors. | ⚠️ at risk if solo |
| Buffer | Jun 29 | Device retest + distribute APKs. iOS spills here. | — |

**Honest call:** Android both flavors + full core API path is achievable. **iOS by the 29th
is the risk.** If solo, declare "Android both flavors by 29th, iOS a few days after."

---

## 5. Feature implementation order (risk × revenue)

**Login → Dashboard → Customer List → Customer Details → Search → Payments → Receipts →
Bluetooth Printing → Offline Sync → Reports → Complaints.**

API integration order = same (auth first; it gates everything).

---

## 6. Creation order (models / repos / providers move together)

| # | Feature | Models (`fromJson`) | Repository methods | Provider methods |
|---|---|---|---|---|
| 1 | Login | `AuthResponse`, `User` | `login()`, `logout()`, `loadToken()` | `AuthProvider.login/logout` + loading/error |
| 2 | Dashboard | `DashboardSummary` | `getDashboard()` | `DashboardProvider.load()` |
| 3 | Customer List | extend `Customer` | `getCustomers(page,filters)` + cache | reuse `CustomerListProvider` (initialLoad/fetch/refresh) |
| 4 | Customer Details | `CustomerDetail` | `getCustomerDetail(id)` | `CustomerDetailProvider.load(id)` |
| 5 | Search | reuse `Customer` | `searchCustomers(q)` | reuse `SearchProvider` |
| 6 | Payments | extend `Payment` + `PaymentRequest` | `createPayment()`, `paymentHistory(id)` | reuse `PaymentController.submit()` |
| 7 | Receipts | `Receipt` | `getReceipt(paymentId)` | `ReceiptProvider.load()` |
| 8 | Printing | `ReceiptPrintModel` | (no API) | `PrinterProvider.print(receipt)` |
| 9 | Offline Sync | reuse `Payment.synced` | `syncPendingPayments()` | reuse `offline_sync_service` |
| 10 | Reports | `MiniDayReport`, `Collection` | `getMiniDayReport()`, `getCollections()` | `ReportProvider.load()` |
| 11 | Complaints | `Complaint` | `getComplaints()`, `createComplaint()` | `ComplaintProvider.load/create` |

---

## 7. Per-feature migration detail (the 9 questions)

> Java files use **patterns** until the real Android repo is shared. Typical structure:
> `*Activity.java` (UI+logic), `ApiClient`/`*Service.java` (Retrofit/Volley), `*Model`/POJOs,
> `DBHelper.java` (SQLiteOpenHelper), util classes.

### 🔑 Login
- **Java:** `LoginActivity`, `ApiClient`/`AuthService`, `SessionManager`/SharedPrefs, response POJO.
- **APIs:** `POST /auth/login` ⬜ confirm path + body + token field.
- **Flutter:** `lib/features/auth/login_screen.dart` (replace demo `admin/123456` in `auth_service.dart`).
- **Models:** `AuthResponse`, `User`.
- **Repo:** `login()`, `logout()`, `loadToken()`.
- **Provider:** `AuthProvider` — `login()`, loading/error.
- **SQLite:** none (token → `secure_storage_service`).
- **Migrate exactly:** auth header format, token expiry, "remember me" rule.
- **Backend-only:** credential validation, token issuance.

### 📊 Dashboard
- **Java:** `DashboardActivity`/`HomeActivity` + summary API + aggregation.
- **APIs:** `GET /dashboard/summary` ⬜.
- **Flutter:** `lib/features/dashboard/dashboard_screen.dart` + `widgets/summary_card.dart`.
- **Models:** `DashboardSummary`.
- **Repo/Provider:** `getDashboard()` / `DashboardProvider.load()`.
- **SQLite:** optional cache.
- **Migrate exactly:** which numbers shown + how computed. **Prefer backend-computed totals.**
- **Backend-only:** all aggregation if API provides it.

### 👥 Customer List
- **Java:** `CustomerListActivity`, `CustomerAdapter`, list API, pagination, `DBHelper` customer table.
- **APIs:** `GET /customers?page=&type=&group=` ⬜.
- **Flutter:** `customer_list_screen.dart`, `nearest_customers_screen.dart`.
- **Models:** extend `Customer` with `fromJson`.
- **Repo:** `getCustomers(page, customerType, group)` → upsert SQLite → return.
- **Provider:** reuse `CustomerListProvider` — point `fetch()` at repo.
- **SQLite:** **reuse existing `customers` table**.
- **Migrate exactly:** filter/group semantics ("Total Unpaid List"), page size, money string format.
- **Backend-only:** filtering/sorting if API does it.

### 🧾 Customer Details
- **Java:** `CustomerDetailActivity`, detail API, POJOs.
- **APIs:** `GET /customers/{id}`, `GET /customers/{id}/payments` ⬜.
- **Flutter:** `customer_details_screen.dart`, `payment_history_screen.dart`.
- **Models:** `CustomerDetail`, reuse `Payment`.
- **Repo/Provider:** `getCustomerDetail(id)` / `CustomerDetailProvider`.
- **SQLite:** reuse `customers`; cache history in `payments`.
- **Migrate exactly:** due/payable computation displayed here.

### 🔍 Search
- **Java:** `SearchActivity`, search API/local query, scan handling.
- **APIs:** `GET /customers/search?q=` + VC/box/serial lookups ⬜.
- **Flutter:** `search_customer_screen.dart`, `scan_customer_screen.dart`.
- **Repo/Provider:** `searchCustomers(q)` / reuse `SearchProvider`.
- **Migrate exactly:** which fields are searchable (VC, box, mobile).

### 💰 Payments — HIGHEST RISK, port exactly
- **Java:** `PaymentActivity`/`CollectActivity`, payment API service, `Payment` POJO, amount/validation util, cash/bank/cheque handling.
- **APIs:** `POST /payments` (create), `GET /payments?...` (history) ⬜.
- **Flutter:** `payment_options_screen.dart`, `payment_details_screen.dart`, `payment_confirmation_dialog.dart`.
- **Models:** `PaymentRequest` (toJson) + extend `Payment` with `fromJson`.
- **Repo:** `createPayment(request)` → success cache `synced=true`; **no-network → write `synced=false` locally** (offline queue).
- **Provider:** reuse `PaymentController.submit()`.
- **SQLite:** **reuse existing `payments` table** (has `synced` flag).
- **⚠️ Migrate exactly:** amount math, rounding, partial-payment rules, cheque fields, transaction-id scheme, exact POST payload. Diff Flutter vs Java for same input before shipping.
- **Backend-only:** ledger posting, balance recompute, receipt-number issuance.

### 🧾 Receipts — port formatting exactly
- **Java:** `ReceiptActivity`, receipt builder/formatter util, receipt POJO.
- **APIs:** `GET /receipts/{paymentId}` or receipt embedded in payment response ⬜.
- **Flutter:** `receipt_preview_screen.dart` (`pdf`/`printing` deps present).
- **Models:** `Receipt`.
- **Repo/Provider:** `getReceipt()` / `ReceiptProvider`.
- **⚠️ Migrate exactly:** layout, line items, totals, header/footer, date format, receipt number (customers compare paper receipts).
- **Backend-only:** receipt number generation.

### 🖨️ Bluetooth Printing — copy the byte commands
- **Java:** Bluetooth printing class — `BluetoothSocket`/`OutputStream` writes, **ESC/POS bytes**, paper width (58/80mm), line feeds, cut command, logo raster.
- **APIs:** none.
- **Flutter:** `printer_settings_screen.dart`, `bluetooth/bluetooth_devices_screen.dart`, `real_bluetooth_service.dart` (`print_bluetooth_thermal`).
- **Models:** `ReceiptPrintModel`.
- **Provider:** `PrinterProvider.print()`.
- **⚠️ Migrate exactly:** ESC/POS command sequence + column widths. Plugin API differs from Java socket, but **bytes sent must match**. Test on the real printer model early.
- **Backend-only:** nothing.

### 🔄 Offline Sync
- **Java:** sync service/`AsyncTask`/`WorkManager`, queue table, retry/conflict rules.
- **APIs:** reuse `POST /payments`; maybe `POST /sync/batch` ⬜.
- **Flutter:** offline screens + `offline_sync_service.dart`, `offline_mode_service.dart` (`connectivity_plus` present).
- **Repo:** `syncPendingPayments()` — read `payments` where `synced=0`, push, mark synced.
- **⚠️ Migrate exactly:** trigger conditions, sync order, duplicate-prevention (idempotency key), conflict resolution. Wrong = double-charge or lost payments.
- **Backend-only:** dedup/idempotency enforcement.

### 📈 Reports (defer if needed)
- **Java:** report activities + report APIs.
- **APIs:** `GET /reports/miniday`, `GET /reports/collections` ⬜.
- **Flutter:** `mini_day_report_screen.dart`, `search_collections_screen.dart`.
- **Models:** `MiniDayReport`, `Collection`.
- **Backend-only:** ALL report aggregation — do not compute client-side.

### 📝 Complaints (defer if needed)
- **Java:** complaint activities + APIs.
- **APIs:** `GET /complaints`, `POST /complaints`, status/package-op endpoints ⬜.
- **Flutter:** complaints/* screens (`other_screens.dart` is a stub — low priority).
- **Models:** `Complaint`.

---

## 8. SQLite tables — reuse map

| Table | Status | Use |
|---|---|---|
| `customers` | exists (`database_helper.dart`, v5) | cache customer list/detail/search |
| `payments` | exists, has `synced` flag | cache history + offline queue |
| collection_schedule / expense | data classes exist | add tables only if those features wired |

Reuse the existing `DatabaseHelper`; do not redesign the schema.

---

## 9. Flavors (CloudDigi / MagikDigi)

> Code currently names flavors `ezy` + `magik` (decision: kept as-is unless renamed).
> Each flavor already carries its own `baseUrl` in `AppConfig` → repositories read
> `AppConfig.instance.baseUrl`.

### Base URL convention (local vs live)
Per-flavor `baseUrl` lives in `main_ezy.dart` / `main_magik.dart`. For local testing,
swap the URL there (or use a `--dart-define`); comment the local line back out for live builds.

### Android (~70% done — `android/app/build.gradle.kts`)
1. ✅ Per-flavor `applicationId` (`com.ezy.cable.digi`, `com.magik.cable.digi`).
2. 🔴 **App name bug:** `AndroidManifest.xml` hardcodes `android:label="ezi_cable_digi"`
   → change to `android:label="@string/app_name"` so flavor `resValue` applies.
3. 🔴 **Release signing:** real keystore + `key.properties` (currently signs with debug key).
4. ⬜ Verify `android/app/google-services.json` contains **both** package names.
5. ⬜ Per-flavor launcher icon under `android/app/src/<flavor>/res/mipmap-*`.
6. ⚠️ Stale `namespace` `com.example.ezi_cable_digi` — confirm it still builds.

### iOS (0% done)
- [ ] Build configs: `Debug-<flavor>` / `Release-<flavor>` for each flavor.
- [ ] Schemes per flavor → correct config + Dart entrypoint (`-t lib/main_<flavor>.dart`).
- [ ] Per-flavor `.xcconfig`: `PRODUCT_BUNDLE_IDENTIFIER`, display name → Info.plist `CFBundleDisplayName`.
- [ ] Per-flavor app icon asset catalogs.
- [ ] **Info.plist permission strings:** `NSLocationWhenInUseUsageDescription`,
      `NSBluetoothAlwaysUsageDescription`, `NSCameraUsageDescription` (missing = crash/rejection).
- [ ] `GoogleService-Info.plist` per bundle ID + run-script copy per config.
- [ ] Apple bundle IDs registered + provisioning profiles for TestFlight.

### Build commands
```bash
flutter run   --flavor ezy   -t lib/main_ezy.dart
flutter run   --flavor magik -t lib/main_magik.dart
flutter build apk --flavor ezy   -t lib/main_ezy.dart   --release
flutter build apk --flavor magik -t lib/main_magik.dart --release
flutter build ipa --flavor magik -t lib/main_magik.dart --release   # after iOS setup
```
**Critical:** the `-t` flag is mandatory. Without it `AppConfig.instance` is never set →
`LateInitializationError` crash on launch.

---

## 10. Release readiness checklist

**Build / Flavors**
- [ ] Both flavors install side-by-side (distinct applicationId/bundleId).
- [ ] Correct app name + icon + baseUrl per flavor.
- [ ] Always built with `--flavor X -t lib/main_X.dart`.

**API**
- [ ] Dio timeouts set.
- [ ] 401 → logout handled in interceptor.
- [ ] Every screen has loading / error / **retry** state.

**Money / Receipts**
- [ ] Flutter payment payload + receipt output **diffed against Java** for identical inputs.
- [ ] Receipt number/format matches Java exactly.

**Printing**
- [ ] Verified on the **real printer model**, both paper widths used in production.

**Offline**
- [ ] Create payment offline → reconnect → syncs exactly once (no duplicates).
- [ ] Cached data shows with no network.

**Crash**
- [ ] Deliberate test crash reaches Crashlytics / `error_handler_service`.
- [ ] No late-init crash per flavor.

**Android**
- [ ] Release-signed (not debug key).
- [ ] `google-services.json` has both packages.

**iOS**
- [ ] Permission usage strings present.
- [ ] Archives for each flavor.

---

## 11. What NOT to do (junior landmines)

- ❌ Rebuild from scratch — deadline killer; working UI is the expensive asset.
- ❌ Migrate Provider→Riverpod or Navigator→GoRouter now — half-done migration is the worst debt.
- ❌ Empty clean-architecture ceremony folders.
- ❌ Forgetting `-t lib/main_X.dart` → `LateInitializationError` crash.
- ❌ Same `applicationId` across flavors → can't install both.
- ❌ One `google-services.json` missing a flavor package → Firebase crash on that flavor.
- ❌ Hardcoding `baseUrl` in screens instead of `AppConfig.instance.baseUrl`.
- ❌ No timeouts / no 401 handling / silent errors (frozen spinner).
- ❌ Computing money/receipts differently from Java → payment discrepancies.
- ❌ Missing iOS Info.plist permission strings → rejection/crash.

---

## 12. Open inputs needed (fill these in)

1. **Real API documentation** — replace every `⬜ confirm` endpoint/payload above with
   actual paths, request bodies, response JSON, and the local/live base-URL pattern.
2. **Android Java source path** — replace pattern-based Java filenames with the real ones;
   copy exact money / receipt / ESC/POS print / sync logic.

### Confirmed facts from current code
- Flutter package: `ezi_cable_digi`; uses `http` (not Dio yet), `provider`, `sqflite`,
  `flutter_secure_storage`, `firebase_core/messaging`, `print_bluetooth_thermal`,
  `pdf`/`printing`, `geolocator`, `mobile_scanner`, `connectivity_plus`.
- Flavors: `ezy` (https://api.ezydigi.com), `magik` (https://api.magikdigi.com).
- Real network calls today: location tracking (`location_sync_service.dart`),
  Google Maps directions (`customer_map_screen.dart`). No business API integration yet.
- Auth is demo only: hardcoded `admin` / `123456` in `auth_service.dart`.
- DB: `database_helper.dart` v5 with `customers` + `payments` tables.
