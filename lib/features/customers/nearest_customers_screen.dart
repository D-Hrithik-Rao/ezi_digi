import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';
import '../customer/customer_map_screen.dart';

class NearestCustomersScreen extends StatefulWidget {
  const NearestCustomersScreen({super.key});

  @override
  State<NearestCustomersScreen> createState() => _NearestCustomersScreenState();
}

class _NearestCustomersScreenState extends State<NearestCustomersScreen> {
  final _db = DatabaseHelper();
  final _distanceController = TextEditingController();
  bool _loading = true;
  bool _mapView = false;
  LatLng? _current;
  List<_CustomerDistance> _customers = [];
  List<_CustomerDistance> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _db.insertDemoData();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final current = LatLng(position.latitude, position.longitude);
    final customers = await _db.getCustomersWithLocation();
    final items = customers.map((c) {
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        c.latitude!,
        c.longitude!,
      );
      return _CustomerDistance(c, distance / 1000);
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    setState(() {
      _current = current;
      _customers = items;
      _filtered = items;
      _loading = false;
    });
  }

  void _applyDistanceFilter() {
    final km = double.tryParse(_distanceController.text.trim());
    if (km == null) {
      setState(() => _filtered = _customers);
      return;
    }
    setState(() {
      _filtered = _customers.where((c) => c.distanceKm <= km).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('NEAREST CUSTOMER')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _distanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter distance in km',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _applyDistanceFilter,
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _mapView = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mapView
                                ? Colors.grey.shade300
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                _mapView ? Colors.black87 : Colors.white,
                          ),
                          child: const Text('View On List'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _mapView = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mapView
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            foregroundColor:
                                _mapView ? Colors.white : Colors.black87,
                          ),
                          child: const Text('View On Map'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _mapView
                      ? _buildMapView()
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final item = _filtered[index];
                            return Card(
                              child: ListTile(
                                title: Text(item.customer.name),
                                subtitle: Text(item.customer.lcoCustomerId),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.location_on, color: Colors.blue),
                                      onPressed: () {
                                        if (_current == null) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CustomerMapScreen(
                                              customer: item.customer,
                                              currentLocation: _current!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Text('${item.distanceKm.toStringAsFixed(2)} km'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
                ],
              ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_current == null) {
      return const Center(child: Text('Current location unavailable'));
    }
    if (_filtered.isEmpty) {
      return const Center(child: Text('No customers in selected range'));
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('agent'),
        position: _current!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your location'),
      ),
      ..._filtered.map(
        (item) => Marker(
          markerId: MarkerId(item.customer.lcoCustomerId),
          position: LatLng(item.customer.latitude!, item.customer.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: item.customer.name,
            snippet: '${item.distanceKm.toStringAsFixed(2)} km',
                          ),
                        ),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _current!,
        zoom: 14,
      ),
      markers: markers,
      myLocationEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      onTap: (_) {},
    );
  }
}

class _CustomerDistance {
  final Customer customer;
  final double distanceKm;

  _CustomerDistance(this.customer, this.distanceKm);
}
