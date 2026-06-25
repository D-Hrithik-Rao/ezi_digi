# DEALER GROUPS (`dg`) — Migration Record

**Status:** 🟡 Implemented; **NOT yet verified complete.** API call works (returned
`status_code=0` with 4 groups once), but a later run returned `status_code=1
"Not a Valid Dealer"`. UI state parity with Android is not yet matched, and manual
UI verification + approval is pending.
**Source of truth:** D:\Git-Repos\magikdigi.

> Sensitive values (URLs, credentials, tokens, dealer IDs, IMEIs) are intentionally omitted.

## Feature purpose
Fetch the dealer's groups to populate the **Group** filter dropdown on the Customer List
screen. The selected group's id feeds the Customer List (`uc`) call.

## Android source files used
- `Fragments/Unpaid_Fragment.java` — the `dealerGroups` Volley form-POST (request params,
  response parsing into the Group spinner).
- `assets/configg.properties` — `dg=/packagelist/dealerGroups`.

## Request (REST, form-encoded POST)
- Endpoint: `NAMESPACE + "/packagelist/dealerGroups"`.
- Content-Type: `application/x-www-form-urlencoded`.
- Params: `dealer_id`, `imei`, `authtoken` (`Unpaid_Fragment` getParams).

## Response fields
- `status_code` (0 = success), `status_msg`.
- `group_details` — a **JSON string** holding `[{ group_id, group_name }, ...]`
  (double-encoded; parse the string, then the array).
- A leading `"Select"` entry with id `0` is prepended for the dropdown
  (Android: `statename.add("Select"); stateid.add(0)`).

## Final implementation details (Flutter)
- **New:** `lib/core/network/rest_client.dart` — minimal form-POST + JSON decode
  (Flutter equivalent of Volley); sends `User-Agent: ksoap2-android/2.6.0+`.
- **New:** `lib/features/customers/data/dealer_groups_repository.dart` — `DealerGroup{id,name}` +
  `fetch()` (POST `dealer_id`/`imei`/`authtoken`, decode `group_details`, prepend `Select`).
- **Modified:** `lib/features/customers/customer_list_provider.dart` — `groups`, `groupNames`,
  `selectedGroupId`, `loadGroups()`.
- **Modified:** `lib/features/customers/customer_list_screen.dart` — Group dropdown items now
  `provider.groupNames`; `loadGroups()` called on screen init.
- Reuses `SessionService` (`authToken`, `dealerId`). No new dependencies.

## Android UI / error states (verified from source — must be mirrored)
| State | Android (`Unpaid_Fragment`) |
|---|---|
| Loading | `ProgressDialog "Loading...Please wait..."` (`:651`) |
| Success (`status_code==0`) | populate Group spinner (with `"Select"` prepended) |
| No data / invalid (`status_code==1`) | **AlertDialog**: message `"No Group Found"`, title = `statusMessage + "!"` (e.g. `"Not a Valid Dealer!"`) |
| Network error | `Toast "Failed."` |
| Cookies/session | **none** — no `CookieManager`/`CookieHandler` in the app; Volley default queue |

## Actual runtime result (local server, magik flavor, physical device)
- 1st open after login: `status_code=0`, `status_msg=Success`, parsed `[Select, DEFAULT, Group2, Group1]` — dropdown populated. ✅
- Later opens (same session/params): `status_code=1`, `status_msg=Not a Valid Dealer`. ⚠️
- Request verified identical to Android params (`dealer_id`, `imei`, `authtoken`); no cookies on either side.

## Known issues
1. **Intermittent `status_code=1 "Not a Valid Dealer"`** on repeat calls with identical params →
   suspected server-side token/session-validity (e.g. concurrent same-dealer login invalidating the token).
   NOT a request-format bug (the success proves the format).
2. **UI state mismatch:** Flutter silently falls back to `[Select]`; Android shows a **loader** +
   **"Not a Valid Dealer!" dialog**. Must mirror Android states.
3. `imei` is a `--dart-define` stand-in (a LIVE-registered device id) used against a LOCAL dealer; Android
   uses the device's real `ANDROID_ID`.

## Verification status (Definition of Done)
- [x] API call succeeds (proven once: 4 groups)
- [ ] UI displays data correctly (needs clean re-test)
- [ ] Android behavior matches (loader + no-data dialog NOT yet implemented)
- [ ] Loading state verified
- [ ] Error / invalid-dealer state verified (Android shows dialog; Flutter silent)
- [ ] Empty state verified
- [ ] Manually tested in-app and **approved by user**

## Remaining work
1. Determine the `status_code=1` cause: clean test (fresh launch → login once → open list once) and confirm
   whether the **Android app** shows groups or a `"Not a Valid Dealer!"` dialog for the same dealer (parity).
2. Mirror Android states in Flutter (loader; "Not a Valid Dealer!"/"No Group Found" dialog; network `"Failed."`).
3. Decide `imei` source (real `ANDROID_ID` vs current override).
