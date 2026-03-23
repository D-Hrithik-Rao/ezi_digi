import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum TrackingScreen { login, dashboard, other }

class LocationSyncService {
  LocationSyncService._();
  static final LocationSyncService instance = LocationSyncService._();

  static const String _trackingEndpoint =
      String.fromEnvironment('TRACKING_ENDPOINT', defaultValue: '');

  static const int _intervalSeconds = 30;

  Timer? _dashboardTimer;
  bool _isSending = false;
  DateTime? _lastSentAt;

  Future<void> onScreenOpened(TrackingScreen screen) async {
    switch (screen) {
      case TrackingScreen.login:
        stopDashboardTracking();
        await _sendLocation(screen: screen, force: true);
        break;
      case TrackingScreen.dashboard:
        await _startDashboardTracking();
        break;
      case TrackingScreen.other:
        stopDashboardTracking();
        break;
    }
  }

  Future<void> _startDashboardTracking() async {
    _dashboardTimer?.cancel();
    // Send immediately on entry, then every interval seconds.
    await _sendLocation(screen: TrackingScreen.dashboard, force: true);
    _dashboardTimer = Timer.periodic(
      const Duration(seconds: _intervalSeconds),
      (_) => _sendLocation(screen: TrackingScreen.dashboard),
    );
  }

  void stopDashboardTracking() {
    _dashboardTimer?.cancel();
    _dashboardTimer = null;
  }

  Future<void> _sendLocation({
    required TrackingScreen screen,
    bool force = false,
  }) async {
    try {
      if (_isSending) return;

      if (!force && _lastSentAt != null) {
        final elapsed = DateTime.now().difference(_lastSentAt!);
        if (elapsed.inSeconds < _intervalSeconds) return;
      }

      final hasPermission = await _ensurePermission();
      if (!hasPermission) return;

      if (_trackingEndpoint.isEmpty) {
        // Keep app working even before backend endpoint is configured.
        return;
      }

      _isSending = true;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await http.post(
        Uri.parse(_trackingEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'screen': screen.name,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      _lastSentAt = DateTime.now();
    } catch (_) {
      // Silent fail for background-like tracking calls.
    } finally {
      _isSending = false;
    }
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
