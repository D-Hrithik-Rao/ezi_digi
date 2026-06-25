# AUTH / LOGIN — Migration Record

**Status:** ✅ Implemented & verified against local server (statusCode=0, authToken received).
**Source of truth:** D:\Git-Repos\magikdigi (MagikDigi Android, production).

> Sensitive values (URLs, credentials, tokens, dealer IDs, IMEIs) are intentionally omitted.

## Feature purpose
Authenticate the user and obtain the session values (`authToken`, `dealerId`, `userType`,
`employeeId`) that every later API depends on. This is the gate to all data calls.

## Android source files used
- `activities/LoginActivity.java` — login flow, server-URL selection, request/response parsing, session statics.
- `complexclasses/validateLoginInfo.java` — ksoap2 request model (field order).
- `activities/AppVersionCheck_Activity.java` — writes the `loginurl` pref (BMS ipAddress); **not used by the production login URL**.
- `activities/CloudAuthentication.java` — BMS registration (logo + ipAddress); does not set the login URL.
- `Utils/EzyCableDigiConstants.java` — `NAMESPACE` / `NAMESPACE_BMS` constants (switched by comment/uncomment).
- `assets/configg.properties` — `LOGIN=validateLogin` (method name).

## Request (SOAP `validateLogin`)
- Transport: SOAP 1.1 (ksoap2 `SoapSerializationEnvelope`, VER11), POST.
- Endpoint: `NAMESPACE + "/wsController"` (the data server; see Session flow).
- SOAPAction: `NAMESPACE + "/validateLogin"`.
- Wrapper property: `userInfo` with `i:type="n0:validateLoginInfo"`.
- Fields (exact order): `UserName`, `PassWord`, `imei`, `appTypeId`, `appTypeAutoId`, `lat`, `lang`.
- Field values observed in production `validateLogin`: `appTypeId=0`, `appTypeAutoId=0`
  (the `login` task leaves them at the int default — `LoginActivity:492-497`); `lat`/`lang` are
  real GPS, or `0.0` when location is unavailable (login still succeeds — `LoginActivity:211-217`).

## Response fields (inside `<parameters>`)
`statusCode` (0 = success), `statusMessage`, `authToken`, `employeeId`, `employeeName`,
`dealerId`, `userType`, `dealerType`, `complaintType`, plus a settings bundle
(`amount_round`, `offlineStatus`, `appTheme`, `use_crf`, `enable_payment_discount`,
`is_sync_bills`, `swipe_scan`, `send_sms`, `box_wise_service_extension`, `pageAccess[]`, …).

## Session flow
1. Splash resolves the data-server URL. **Login URL = `NAMESPACE + "/wsController"`.**
   The BMS-returned `ipAddress` is **NOT** used for the login URL in the production package
   (`itp.com.magikdigi`): `LoginActivity:167` skips the prefs-override block for that package,
   so the static default at `LoginActivity:75` holds.
2. User submits credentials → SOAP `validateLogin`.
3. On `statusCode=0`, the session values are kept in memory (Android: `public static` fields on
   `LoginActivity`; **not persisted**). Every later API reads `authToken` (+ `dealerId` for
   list/payment calls).

## Final implementation details (Flutter)
- **New:** `lib/core/network/soap_client.dart` — emits the ksoap2 VER11 envelope
  (`<v:Envelope … i:/d:/c:/v:>`, `<v:Header/>`, `<n0:method xmlns:n0=…>`,
  `<userInfo i:type="n0:validateLoginInfo">`), sends `User-Agent: ksoap2-android/2.6.0+`.
- **New:** `lib/core/network/server_url_resolver.dart` — `loginServerUrl = NAMESPACE + "/wsController"`;
  `resolve()` calls BMS for registration/logo parity only (does not set the login URL).
- **New:** `lib/core/services/session_service.dart` — in-memory `authToken`/`dealerId`/`userType`/`employeeId`
  (mirrors Android statics; not persisted).
- **Modified:** `lib/core/services/auth_service.dart` — `login()` (SOAP `validateLogin`) + `LoginResult`.
- **Modified:** `lib/features/auth/login_screen.dart` — calls `login()`, shows server `statusMessage` on failure.
- **Modified:** `lib/features/auth/splash_screen.dart` — runs `resolve()` before Login.
- **Modified:** `lib/core/config/app_config.dart` — `namespace`/`namespaceBms` (comment/uncomment), `appTypeId`/`appTypeAutoId`.
- **Modified:** `android/app/src/main/AndroidManifest.xml` — `usesCleartextTraffic="true"` (servers are http).
- No new dependencies. Architecture unchanged (Provider/Navigator/folder layout).

## Testing performed
- Local server, magik flavor on a physical Android device.
- Verified: login POSTs to `NAMESPACE + "/wsController"` (local); request envelope byte-matches
  the Android production request; server returned HTTP 200, `statusCode=0`, `statusMessage=Success`,
  with a valid `authToken`, `dealerId`, and `userType=DEALER`; session populated; navigation past login.
- Negative: wrong credentials returned `statusCode=1` with the server's message (no token).

## Known differences vs Android
| Area | Android | Flutter | Required to fix? |
|---|---|---|---|
| `imei` source | `Settings.Secure.ANDROID_ID` | `--dart-define=DEVICE_IMEI` override | No (test stand-in; real ANDROID_ID via `device_info_plus` later) |
| `lat`/`lang` | real GPS, else `0.0` | always `0.0` | No (login succeeds with `0.0`, proven in source) |
| Session persistence | in-memory statics | in-memory `SessionService` | No (faithful) |
| SOAP serialization | ksoap2 (typed envelope) | hand-built identical envelope | No (byte-matched) |
