import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'soap_client.dart';

/// Resolves the data-server URL exactly the way MagikDigi Android does.
///

/// POSTs `validateLogin` to `NAMESPACE + "/wsController"` and IGNORES the
/// BMS-returned `ipAddress` for the login URL:
///   • LoginActivity:  login_serverUrl = NAMESPACE + "/wsController"  // static default
///   • LoginActivity: the prefs-override block runs ONLY for non-production
///                       packages, so the production app keeps the static default.
///   • AppVersionCheck stores the BMS ipAddress to prefs, but production
///     LoginActivity never reads it.
/// → login_serverUrl is driven by NAMESPACE (the commentable const in AppConfig),
///   NOT by BMS. We mirror that exactly.
///
/// BMS (resolve()) is still called for registration / logo parity, but it does
/// NOT determine the login URL.
class ServerUrlResolver {
  ServerUrlResolver._();
  static final ServerUrlResolver instance = ServerUrlResolver._();

  static const String _kAppLogoPath = 'app_logo_path';

  static String get _imeiOverride => AppConfig.deviceImei;

  String _appLogoPath = '';

  /// The login URL = NAMESPACE + "/wsController" .
  String get loginServerUrl => '${AppConfig.namespace}/wsController';

  /// NAMESPACE (Android: EzyCableDigiConstants.NAMESPACE).
  String get namespace => AppConfig.namespace;

  String get appLogoPath => _appLogoPath;

  /// Load the cached logo. (The login URL does not depend on prefs.)
  Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    _appLogoPath = prefs.getString(_kAppLogoPath) ?? _appLogoPath;
  }

  /// Calls BMS for registration / logo parity (Android: CloudAuth at startup).
  /// Does NOT set the login URL — production Android ignores the BMS ipAddress
  /// for login. Safe to fail (e.g. BMS busy): login_serverUrl is independent.
  Future<bool> resolve() async {
    try {
      final xml = await SoapClient.instance.call(
        url: '${AppConfig.namespaceBms}/validateAuthentication',
        namespace: AppConfig.namespaceBms,
        soapAction: '${AppConfig.namespaceBms}/validateUserAuthentication',
        methodName: 'validateUserAuthentication',
        wrapper: 'userInfo',
        wrapperType: 'validateAuthenticationInfo',
        fields: {
          'smsCode': '',
          'imei': _imeiOverride,
          'appTypeId': AppConfig.instance.appTypeId,
          'appTypeAutoId': AppConfig.instance.appTypeAutoId,
        },
      );
      final statusCode = SoapClient.readField(xml, 'statusCode');
      _appLogoPath = SoapClient.readField(xml, 'appLogoPath') ?? _appLogoPath;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAppLogoPath, _appLogoPath);
      return statusCode == '0';
    } catch (_) {
      return false; // BMS unreachable/busy — login_serverUrl is independent.
    }
  }
}
