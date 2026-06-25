import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ezi_cable_digi/core/config/app_config.dart';
import 'package:http/http.dart' as http;

import '../../core/data/customer.dart';

class CustomerMapScreen extends StatefulWidget {
  final Customer customer;
  final LatLng currentLocation;

  const CustomerMapScreen({
    super.key,
    required this.customer,
    required this.currentLocation,
  });

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  StreamSubscription<Position>? _posSub;

  late LatLng _current;
  late LatLng _customerPoint;

  // Straight line polyline between current and customer (always updated).
  Set<Polyline> _polylines = {};

  // Road-route polyline from Directions API (updated occasionally).
  List<LatLng> _routePolyline = [];
  bool _isRouteLoading = false;
  DateTime? _lastRouteFetchAt;
  LatLng? _lastRouteOrigin;

  GoogleMapController? _mapController;
  DateTime? _lastCameraMoveAt;

  static String get _googleMapsApiKey => AppConfig.instance.googleMapsApiKey;

  @override
  void initState() {
    super.initState();
    _current = widget.currentLocation;

    if (widget.customer.latitude == null || widget.customer.longitude == null) {
      _customerPoint = const LatLng(0, 0);
    } else {
      _customerPoint = LatLng(widget.customer.latitude!, widget.customer.longitude!);
    }

    _refreshPolylines();
    _startLocationStream();
    _tryFetchRoutePolylineOnce();
  }

  void _refreshPolylines() {
    final straightPoints = <LatLng>[_current, _customerPoint];

    if (_routePolyline.isNotEmpty) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('straight'),
          points: straightPoints,
          width: 3,
          color: Colors.blue.withValues(alpha: 0.35),
        ),
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePolyline,
          width: 5,
          color: Colors.blue,
        ),
      };
      return;
    }

    _polylines = {
      Polyline(
        polylineId: const PolylineId('straight'),
        points: straightPoints,
        width: 4,
        color: Colors.blue,
      ),
    };
  }

  Future<void> _startLocationStream() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).listen((pos) {
        if (!mounted) return;

        final next = LatLng(pos.latitude, pos.longitude);
        final movedMeters = Geolocator.distanceBetween(
          _current.latitude,
          _current.longitude,
          next.latitude,
          next.longitude,
        );

        setState(() {
          _current = next;
          _refreshPolylines();
        });

        // Update road route only occasionally to keep it smooth.
        if (_googleMapsApiKey.isEmpty) return;

        final lastOrigin = _lastRouteOrigin;
        final lastFetchAt = _lastRouteFetchAt;
        final shouldRefresh = lastOrigin == null ||
            lastFetchAt == null ||
            DateTime.now().difference(lastFetchAt).inSeconds >= 180;

        if (shouldRefresh && lastOrigin != null) {
          if (movedMeters >= 250) {
            _fetchRouteIfNeeded(force: false);
          }
        } else if (lastOrigin == null) {
          _fetchRouteIfNeeded(force: false);
        }

        // Follow the agent smoothly (avoid jitter).
        if (_mapController != null) {
          final now = DateTime.now();
          final timeOk = _lastCameraMoveAt == null ||
              now.difference(_lastCameraMoveAt!).inSeconds >= 5;
          if (timeOk && movedMeters >= 50) {
            _lastCameraMoveAt = now;
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(next),
            );
          }
        }
      });
    } catch (error, stackTrace) {
      debugPrint('CustomerMapScreen: location stream failed: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> _tryFetchRoutePolylineOnce() async {
    if (_googleMapsApiKey.isEmpty) return;
    await _fetchRouteIfNeeded(force: true);
  }

  Future<void> _fetchRouteIfNeeded({required bool force}) async {
    if (!mounted) return;
    if (_isRouteLoading) return;
    if (_customerPoint.latitude == 0 && _customerPoint.longitude == 0) return;

    try {
      if (!force && _lastRouteFetchAt != null) {
        if (DateTime.now().difference(_lastRouteFetchAt!).inSeconds < 180) {
          return;
        }
      }

      if (!force && _lastRouteOrigin != null) {
        final movedMeters = Geolocator.distanceBetween(
          _lastRouteOrigin!.latitude,
          _lastRouteOrigin!.longitude,
          _current.latitude,
          _current.longitude,
        );
        if (movedMeters < 250) return;
      }

      _isRouteLoading = true;

      final origin = '${_current.latitude},${_current.longitude}';
      final destination = '${_customerPoint.latitude},${_customerPoint.longitude}';

      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        <String, String>{
          'origin': origin,
          'destination': destination,
          'mode': 'driving',
          'key': _googleMapsApiKey,
        },
      );

      final res =
          await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return;

      final routes = (data['routes'] as List<dynamic>?) ?? [];
      if (routes.isEmpty) return;

      final route = routes.first as Map<String, dynamic>;
      final overview =
          (route['overview_polyline'] as Map<String, dynamic>?) ?? {};
      final encoded = overview['points'] as String?;
      if (encoded == null || encoded.isEmpty) return;

      final decoded = _decodeGooglePolyline(encoded);
      if (!mounted) return;

      setState(() {
        _routePolyline = decoded;
        _lastRouteFetchAt = DateTime.now();
        _lastRouteOrigin = _current;
        _refreshPolylines();
      });
    } catch (error, stackTrace) {
      debugPrint('CustomerMapScreen: route fetch failed: $error');
      debugPrint(stackTrace.toString());
      // Keep straight polyline if route fails.
    } finally {
      _isRouteLoading = false;
    }
  }

  // Google polyline decoding algorithm.
  List<LatLng> _decodeGooglePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomerLocation =
        widget.customer.latitude != null && widget.customer.longitude != null;
    if (!hasCustomerLocation) {
      return Scaffold(
        appBar: AppBar(title: const Text('CUSTOMER LOCATION')),
        body: const Center(
          child: Text('Location not available for this customer'),
        ),
      );
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('current'),
        position: _current,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: _customerPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text('${widget.customer.name} Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _customerPoint,
              zoom: 16,
            ),
            markers: markers,
            polylines: _polylines,
            myLocationEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 14, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        'Your location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_current.latitude},${_current.longitude}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (_isRouteLoading)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Finding best route...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
