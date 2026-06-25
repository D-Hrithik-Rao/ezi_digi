# DEVICE ID (`imei`) STRATEGY

**Status:** ✅ Verified against MagikDigi Android source.
**Source of truth:** D:\Git-Repos\magikdigi.

> No sensitive values stored here. The dev fallback id lives only in `AppConfig` (debug-only).

## What Android does (verified)
`LoginActivity.java:265-268` (and `CloudAuthentication`):
```java
if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) imeiNo = telephonyManager.getDeviceId(); // ≤ A9
else imeiNo = Settings.Secure.getString(..., Settings.Secure.ANDROID_ID);                    // A10+
```
- **Android 10+ → `Settings.Secure.ANDROID_ID`** (a 64-bit hex string).
- Android always sends a real value; there is **no client-side empty check** (only username/password).
- The server **requires** a valid `imei`: every request model includes it — Login, BMS, Search (`sc`),
  Customer List (`uc`), Get Pending Amount (`gpa`), Make Payment (`mpay`), Dealer Groups (`dg`).
- Observed: a request with an **empty** `imei` fails (login does not succeed).

## Current Flutter implementation (temporary)
Single source — `AppConfig.deviceImei` (`lib/core/config/app_config.dart`):
```dart
static String get deviceImei {
  const overridden = String.fromEnvironment('DEVICE_IMEI', defaultValue: '');
  if (overridden.isNotEmpty) return overridden;          // 1) any build, if provided
  return kReleaseMode ? '' : 'db569a6f4e066ede';         // 2) debug → dev id · 3) release → empty
}
```
All callers read `AppConfig.deviceImei` (auth_service, server_url_resolver, and the
dealer-groups / customer-list / search / pending-amount repositories).

## Why the debug fallback exists
Local login/`gpa`/etc. need a **registered** device id. The Flutter dev build's own device id
isn't registered on the local server, so we use a **known-registered** ANDROID_ID
(`db569a6f4e066ede`) as the debug default — this lets `flutter run --flavor magik -t lib/main_magik.dart`
work without remembering `--dart-define`. It is a developer convenience only.

## Production-safe behaviour
| Build | `imei` value | Effect |
|---|---|---|
| Debug / profile | dev ANDROID_ID (`db569…`) | local testing works |
| Release (no flag) | **empty** | login fails *safely* — forces a real id to be wired before shipping (no shared hardcoded id leaks to users) |
| Any build + `--dart-define=DEVICE_IMEI=…` | that value | explicit override |

So a production APK can **never** silently ship the dev id to all users.

## When to use `--dart-define`
- Testing against a **different registered device**: `--dart-define=DEVICE_IMEI=<that id>`.
- Any release/QA build until `device_info_plus` is wired.

## Migration plan → real ANDROID_ID (before production)
1. Add `device_info_plus`; read `Settings.Secure.ANDROID_ID` (Android) — mirrors Android exactly.
2. In `AppConfig.deviceImei`: keep `--dart-define` override → else real ANDROID_ID → (debug-only) dev fallback.
3. ⚠️ **Registration caveat:** ANDROID_ID is per-app-signing-key since Android 8, so the **Flutter app's
   ANDROID_ID differs from the Java app's** on the same device. The server will treat the Flutter app as a
   **new device** → it must go through BMS registration (the splash `validateAuthentication` flow). Plan/test
   the registration path before go-live.
4. iOS has no ANDROID_ID/IMEI → decide the iOS device id (e.g. `identifierForVendor`) and confirm the server accepts it.

## Device-registration lifecycle (verified from Android — `CloudAuthentication.java`)
Registration is a SEPARATE flow from login, and it's what binds a device's ANDROID_ID on the server.

1. **Entry screen** = `CloudAuthentication` (shown on a new/unregistered device). It has an **SMS Key**
   input (`auth_et_smskey`) + a register button.
2. The dealer types the **SMS Key** (issued by the backend, typically via SMS) and submits. The app calls
   the BMS endpoint **`validateAuthentication`** with:
   `smsCode = <the key>`, `imei = ANDROID_ID`, `appTypeId = 3`, `appTypeAutoId = <tenant>`.
3. **BMS binds the ANDROID_ID server-side** when the key validates → `statusCode==0`
   ("Registration Successful") → returns the server `ipAddress` → proceed to Login.
4. **Already-registered device:** the same `validateAuthentication` call runs with `smsCode` **empty**
   and just returns the server URL (no key needed).
5. **Unknown / unregistered ANDROID_ID:** `statusCode==1/2` → "Registration Failed! …" and the device
   **cannot reach Login** until a valid SMS Key registers it. (`registrationRequired` gates this.)

**Who registers:** dealer-initiated (enters the key) + backend-controlled (issues the key) + BMS-performed
(binds the id). A dealer cannot register an arbitrary device without a valid backend-issued SMS Key.

### Implication for the Flutter migration
The Flutter app's ANDROID_ID is a **new** id (per-app-signing-key on Android 8+), so on a real install it is
**unregistered** → production Flutter MUST implement this **SMS-Key registration screen** (the
`CloudAuthentication` equivalent) before login. The current hardcoded dev id only works because it is an
**already-registered** id — a development shortcut, not the production path.

## What MUST change before production release
- [ ] Wire a real device id (`device_info_plus`) — release currently sends empty `imei` by design.
- [ ] **Implement the SMS-Key device-registration screen** (`CloudAuthentication` flow) so a new Flutter
      install can register its ANDROID_ID via BMS `validateAuthentication` (`smsCode`).
- [ ] Verify BMS registration end-to-end for the Flutter app's id.
- [ ] Decide + verify the iOS device id (+ its registration).
