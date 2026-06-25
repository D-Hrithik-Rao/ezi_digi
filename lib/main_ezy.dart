import 'core/config/app_config.dart';
import 'main.dart';


void main() {
  AppConfig.instance = AppConfig(
    appName: "Ezy Cable Digi",
    baseUrl: "https://api.ezydigi.com",
    flavor: Flavor.ezy,
    appTypeAutoId: 0, // TODO: confirm CloudDigi (ezycable) appTypeAutoId before using this flavor
    trackingEndpoint: const String.fromEnvironment('TRACKING_ENDPOINT', defaultValue: ''),
    googleMapsApiKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: ''),
  );

  mainEntry();
}