import 'package:flutter/foundation.dart' show kReleaseMode;

enum Flavor { ezy, magik }

class AppConfig {
  final String appName;
  final String baseUrl;
  final Flavor flavor;
  final String trackingEndpoint;
  final String googleMapsApiKey;

  // Sent in BMS + Login requests (Android sends both).
  final int appTypeId; // 3 = CableDigi
  final int appTypeAutoId; // tenant id: 8 = MagikDigi / KCCL

  static late AppConfig instance;

  // ── Mirror of Android EzyCableDigiConstants (NAMESPACE / NAMESPACE_BMS) ──────
  // Switch environment : comment/uncomment a line.
  // NAMESPACE_BMS — the BMS server. The BMS
  // is a SEPARATE host from the data server (NAMESPACE):
  static const String namespaceBms = 'http://ezybms.itpworld.com/index.php';      // LIVE
  // static const String namespaceBms =
  //     'http://192.168.1.98/ezybms_m8/app/index.php'; // LOCAL (active)
  // static const String namespaceBms = 'http://192.168.1.16/ezybmsys/app/index.php'; // LOCAL alt
  //
  // NAMESPACE — the data server .
  // login_serverUrl defaults to NAMESPACE + "/wsController".
  // static const String namespace = 'http://digi.kccl.tv/index.php';      // LIVE MagikDigi
  // static const String namespace = 'http://digi.ezycable.com/index.php'; // LIVE CloudDigi
  static const String namespace =
      'http://192.168.1.16/testing/ezycabledigi_v2_H8_cloud_live/app/index.php'; // LOCAL (active)

  // Device id sent as `imei`. DEV-ONLY fallback — see server docs/DEV_SETUP.md.
  // Resolution order:
  //   1) --dart-define=DEVICE_IMEI=…  → used in ANY build (debug or release)
  //   2) debug / profile builds       → a known-registered DEV device id (local login works)
  //   3) release builds               → EMPTY — production MUST supply a real device id
  //      (via --dart-define, or later device_info_plus ANDROID_ID). This prevents a
  //      release APK from shipping one shared hardcoded imei to all users.
  static String get deviceImei {
    const overridden = String.fromEnvironment('DEVICE_IMEI', defaultValue: '');
    if (overridden.isNotEmpty) return overridden;
    return kReleaseMode ? '' : 'db569a6f4e066ede';
  }

  AppConfig({
    required this.appName,
    required this.baseUrl,
    required this.flavor,
    this.trackingEndpoint = '',
    this.googleMapsApiKey = '',
    this.appTypeId = 3,
    required this.appTypeAutoId,
  });
}
