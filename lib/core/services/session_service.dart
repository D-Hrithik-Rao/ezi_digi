/// Holds the logged-in session values for the lifetime of the app process.
///
/// This is the Flutter equivalent of the Android app's `public static` fields on
/// `LoginActivity` (`authToken`, `dealerId`, `userType`, `employeeId`). Like
/// Android, these are kept **in memory only** — they are NOT persisted, so an
/// app kill means the user logs in again. Every later API reads from here, just
/// as Android reads `LoginActivity.authToken` / `LoginActivity.dealerId`.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  String authToken = '';
  String dealerId = '';
  String userType = '';
  String employeeId = '';

  bool get isLoggedIn => authToken.isNotEmpty;

  void setFromLogin({
    required String authToken,
    required String dealerId,
    required String userType,
    required String employeeId,
  }) {
    this.authToken = authToken;
    this.dealerId = dealerId;
    this.userType = userType;
    this.employeeId = employeeId;
  }

  void clear() {
    authToken = '';
    dealerId = '';
    userType = '';
    employeeId = '';
  }
}
