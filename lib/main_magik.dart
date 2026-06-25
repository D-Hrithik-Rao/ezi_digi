import 'core/config/app_config.dart';
import 'main.dart';

void main() {
  AppConfig.instance = AppConfig(
    appName: "Magik Digi",
    baseUrl: "https://api.magikdigi.com",
    flavor: Flavor.magik,
    appTypeAutoId: 8, // MagikDigi / KCCL (from Android: appTypeAutoId)
    trackingEndpoint: const String.fromEnvironment('TRACKING_ENDPOINT', defaultValue: ''),
    googleMapsApiKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: ''),
  );

  mainEntry();
}