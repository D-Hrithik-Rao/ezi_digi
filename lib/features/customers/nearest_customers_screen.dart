import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/theme_constants.dart';
import '../../core/widgets/premium_dialog.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPremiumLoading(context, message: 'Finding Nearby Customers...');
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
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

      if (mounted) Navigator.of(context).pop(); // dismiss loading

      setState(() {
        _current = current;
        _customers = items;
        _filtered = items;
        _loading = false;
      });
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // dismiss loading
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location. Please enable GPS.')),
        );
      }
    }
  }

  void _applyDistanceFilter() {
    final km = double.tryParse(_distanceController.text.trim());
    setState(() {
      _filtered =
      km == null ? _customers : _customers.where((c) => c.distanceKm <= km).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: AppBar(
        backgroundColor: t.appBarBg,
        foregroundColor: t.appBarFg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: t.backBtnBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: t.backBtnIcon),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NEAREST CUSTOMER',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
              letterSpacing: 1.1, color: t.appBarFg),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────
            Padding(
              padding:
              const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _distanceController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter distance in km',
                          hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.35),
                              fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _applyDistanceFilter,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.search,
                            color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Toggle buttons ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleBtn(
                      label: 'View On List',
                      active: !_mapView,
                      onTap: () => setState(() => _mapView = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ToggleBtn(
                      label: 'View On Map',
                      active: _mapView,
                      onTap: () => setState(() => _mapView = true),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────
            Expanded(
              child: _mapView ? _buildMapView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('No customers found',
            style: TextStyle(color: Colors.black45)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final item = _filtered[index];
        return _CustomerCard(
          item: item,
          current: _current,
          onNavigate: () {
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
        );
      },
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
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your location'),
      ),
      ..._filtered.map(
            (item) => Marker(
          markerId: MarkerId(item.customer.lcoCustomerId),
          position:
          LatLng(item.customer.latitude!, item.customer.longitude!),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: item.customer.name,
            snippet: '${item.distanceKm.toStringAsFixed(2)} km',
          ),
        ),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _current!, zoom: 14),
      markers: markers,
      myLocationEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      onTap: (_) {},
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Customer card — fixed height with proper layout, no overflow
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final _CustomerDistance item;
  final LatLng? current;
  final VoidCallback onNavigate;

  const _CustomerCard({
    required this.item,
    required this.current,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: t.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: t.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.customer.name.isNotEmpty
                    ? item.customer.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: t.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.customer.lcoCustomerId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Distance + location button
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onNavigate,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Iconsax.location, color: t.accent, size: 20),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${item.distanceKm.toStringAsFixed(2)} km',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: t.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Button
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? t.toggleActiveBg : t.toggleInactiveBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: active
                  ? t.toggleActiveBg.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? t.toggleActiveText : t.toggleInactiveText,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerDistance {
  final Customer customer;
  final double distanceKm;
  _CustomerDistance(this.customer, this.distanceKm);
}