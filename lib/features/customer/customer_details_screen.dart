import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/theme_constants.dart';
import '../../core/widgets/premium_dialog.dart';
import '../payment/payment_options_screen.dart';
import 'customer_map_screen.dart';
import 'location_preview_screen.dart';
import 'payment_history_screen.dart';
import '../complaints/create_complaint_screen.dart';
import '../complaints/complaints_history_screen.dart';
import '../billing/invoice_history_screen.dart';
import '../complaints/package_operations_screen.dart';
import '../complaints/deactivate_stb_screen.dart';
import '../complaints/other_screens.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper();
  late Customer _customer;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: _buildAppBar(t),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerInfoCard(t),
              const SizedBox(height: 12),
              _buildLocationCard(t),
              const SizedBox(height: 12),
              _buildOperationsCard(t),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(AppThemeConst t) {
    return AppBar(
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
        'CUSTOMER DETAILS',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: t.appBarFg,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: _openCustomerMap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.location_on,
                  color: Colors.redAccent, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Customer Info Card ──────────────────────────────────────────────────
  Widget _buildCustomerInfoCard(AppThemeConst t) {
    return _WhiteCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Customer Name', _customer.name, t),
          _infoRow('Nick Name',
              _customer.nickName.isEmpty ? 'N/A' : _customer.nickName, t),
          _infoRow('Mobile Number', _customer.primaryMobileNumber, t,
              copyable: true, hasCallIcon: true),
          _infoRow('Total Due', _customer.totalDue, t,
              valueColor: AppColors.textPrimary, valueBold: true),
          _infoRow('Amount Payable', _customer.amountPayable, t,
              valueColor: t.accent, valueBold: true),
          _infoRow('Customer Type', _customer.customerType, t),
          _infoRow('Group Name',
              _customer.groupName.isEmpty ? 'N/A' : _customer.groupName, t),
          _infoRow('Area Name',
              _customer.areaName.isEmpty ? 'N/A' : _customer.areaName, t),
          _infoRow(
              'Address',
              _customer.address.isEmpty ? 'N/A' : _customer.address, t,
              isLast: true,
              hasMoreIcon: true),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    AppThemeConst t, {
    Color? valueColor,
    bool valueBold = false,
    bool copyable = false,
    bool hasCallIcon = false,
    bool hasMoreIcon = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.cardSubtitleText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: valueBold ? FontWeight.w800 : FontWeight.w700,
                          color: valueColor ?? t.cardBodyText,
                        ),
                      ),
                    ),
                    if (hasCallIcon)
                      GestureDetector(
                        onTap: () => _confirmAndCall(value),
                        child: const Icon(Icons.call, size: 15, color: Colors.green),
                      ),
                    if (hasCallIcon) const SizedBox(width: 6),
                    if (copyable)
                      GestureDetector(
                        onTap: () => _showUpdateMobileDialog(value),
                        child: const Icon(Icons.edit, size: 15, color: Color(0xFF9CA3AF)),
                      ),
                    if (hasMoreIcon)
                      Icon(Icons.more_vert, size: 15, color: t.accent),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: t.dividerColor),
      ],
    );
  }

  // ── Location Card ────────────────────────────────────────────────────────
  Widget _buildLocationCard(AppThemeConst t) {
    return _WhiteCard(
      t: t,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 6),
              Text(
                'LOCATION',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: t.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Divider(color: t.accent, thickness: 1.2),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _locCell(_customer.lastPaidDate, 'Last Paid Date', t: t),
              ),
              _locDivider(t),
              Expanded(
                child: _locCell(_customer.billMonth, 'Bill Month', t: t),
              ),
              _locDivider(t),
              Expanded(
                child: _locCell(
                  _customer.lcoCustomerId,
                  'LCO Customer id',
                  t: t,
                  hasEditIcon: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _locCell(
                  _customer.boxNumber,
                  'Box Number',
                  t: t,
                  valueColor: Colors.green.shade600,
                ),
              ),
              _locDivider(t),
              Expanded(
                child: _locCell(
                  _customer.vcNumber,
                  'VC Number',
                  t: t,
                  valueColor: Colors.green.shade600,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _locDivider(AppThemeConst t) => Container(
        width: 1,
        height: 40,
        color: t.dividerColor,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _locCell(
    String value,
    String label, {
    Color? valueColor,
    bool hasEditIcon = false,
    required AppThemeConst t,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: valueColor ?? t.accent,
              ),
            ),
            if (hasEditIcon) ...[
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 14, color: Color(0xFF9CA3AF)),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: t.cardSubtitleText,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Operations Card ────────────────────────────────────────────────────
  Widget _buildOperationsCard(AppThemeConst t) {
    final ops = [
      _Op(Iconsax.money_send,      'Make Payments',      [const Color(0xFF7B5EA7), const Color(0xFF9C6FE4)]),
      _Op(Iconsax.clock,           'Payment History',    [const Color(0xFFD4A017), const Color(0xFFF5C842)]),
      _Op(Iconsax.message_question,'Create Complaints',  [const Color(0xFF607D8B), const Color(0xFF90A4AE)]),
      _Op(Iconsax.location,        'Update Location',    [const Color(0xFF1976D2), const Color(0xFF42A5F5)]),
      _Op(Iconsax.document,        'Invoice History',    [const Color(0xFF5C35B1), const Color(0xFF7E57C2)]),
      _Op(Iconsax.message_text,    'Complaint History',  [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)]),
      _Op(Iconsax.box,             'Package Operations', [const Color(0xFFE65100), const Color(0xFFFF8C42)]),
      _Op(Icons.tv,                'Deactivate STB',     [const Color(0xFFB71C1C), const Color(0xFFEF5350)]),
      _Op(Iconsax.chart,           'Act-Deact Report',   [const Color(0xFFEF6C00), const Color(0xFFFFA726)]),
      _Op(Iconsax.timer_1,         'One Time Charges',   [const Color(0xFF00796B), const Color(0xFF26A69A)]),
      _Op(Iconsax.receipt_1,       'One Time History',   [const Color(0xFF1565C0), const Color(0xFF42A5F5)]),
      _Op(Iconsax.clock,           'Pay Later',          [const Color(0xFF558B2F), const Color(0xFF9CCC65)]),
    ];

    return _WhiteCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOMER OPERATIONS',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: t.accent, letterSpacing: 0.4),
          ),
          Divider(color: t.accent, thickness: 1.2),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.88,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
            ),
            itemCount: ops.length,
            itemBuilder: (_, i) => _OpItem(
              icon: ops[i].icon,
              label: ops[i].label,
              gradientColors: ops[i].gradientColors,
              t: t,
              onTap: () => _handleOp(ops[i].label),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOp(String label) {
    switch (label) {
      case 'Make Payments':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentOptionsScreen(customer: _customer)));
        break;
      case 'Update Location':
        _showUpdateLocationDialog();
        break;
      case 'Payment History':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen(customer: _customer)));
        break;
      case 'Create Complaints':
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateComplaintScreen(customer: _customer)));
        break;
      case 'Complaint History':
        Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintHistoryScreen(customer: _customer)));
        break;
      case 'Invoice History':
        Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceHistoryScreen(customer: _customer)));
        break;
      case 'Package Operations':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PackageOperationsScreen(customer: _customer)));
        break;
      case 'Deactivate STB':
        Navigator.push(context, MaterialPageRoute(builder: (_) => DeactivateStbScreen(customer: _customer)));
        break;
      case 'Act-Deact Report':
        Navigator.push(context, MaterialPageRoute(builder: (_) => ActDeactReportScreen(customer: _customer)));
        break;
      case 'One Time Charges':
        Navigator.push(context, MaterialPageRoute(builder: (_) => OneTimeChargesScreen(customer: _customer)));
        break;
      case 'One Time History':
        Navigator.push(context, MaterialPageRoute(builder: (_) => OneTimeHistoryScreen(customer: _customer)));
        break;
      case 'Pay Later':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PayLaterScreen(customer: _customer)));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label coming soon')));
    }
  }

  Future<void> _showUpdateMobileDialog(String currentMobile) async {
    final controller = TextEditingController(text: currentMobile);
    final result = await showPremiumDialog<bool>(
      context: context,
      child: PremiumDialogShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Update Mobile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Current: $currentMobile', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'New mobile number',
                  hintStyle: const TextStyle(fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('UPDATE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != true) return;
    final newMobile = controller.text.trim();
    if (newMobile.isEmpty || newMobile == currentMobile) return;
    setState(() { _customer = _customer.copyWith(primaryMobileNumber: newMobile); });
    controller.dispose();
  }

  Future<void> _confirmAndCall(String mobile) async {
    if (mobile.isEmpty) return;
    final shouldCall = await showPremiumConfirm(
      context: context,
      title: 'Make a Call',
      body: 'Call $mobile?',
      confirmLabel: 'CALL',
      cancelLabel: 'CANCEL',
    );
    if (!shouldCall) return;
    final uri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      showPremiumSnackBar(context, 'Unable to open dialer', isError: true);
    }
  }

  Future<void> _showUpdateLocationDialog() async {
    final controller = TextEditingController(text: _customer.areaName);
    final confirmed = await showPremiumDialog<bool>(
      context: context,
      child: PremiumDialogShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.location, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Update Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Enter area name',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Iconsax.location, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('PROCEED', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    final areaName = controller.text.trim();
    if (areaName.isEmpty) return;
    controller.dispose();

    // ── GPS fetch ────────────────────────────────────────────────────────
    // mounted is guaranteed here — no await has occurred in this code path yet.
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    final nav       = Navigator.of(context);
    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    // ignore: use_build_context_synchronously
    showPremiumLoading(context, message: 'Getting GPS location...');
    late double lat, lng;
    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      lat = position.latitude;
      lng = position.longitude;
      if (!mounted) return;
      nav.pop(); // dismiss loading
    } catch (e) {
      if (mounted) {
        nav.pop();
        messenger.showSnackBar(SnackBar(
          content: Text('Location failed: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
      return;
    }

    // ── Location preview push ─────────────────────────────────────────────
    if (!mounted) return;
    final previewAccepted = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => LocationPreviewScreen(
          customerName: _customer.name,
          areaName: areaName,
          location: LatLng(lat, lng),
        ),
      ),
    );
    if (previewAccepted != true || !mounted) return;

    // ── Save confirm ──────────────────────────────────────────────────────
    final shouldSave = await showPremiumConfirm(
      context: context,
      title: 'Save Location',
      body: 'Save GPS location for ${_customer.name}?',
      confirmLabel: 'SAVE',
    );
    if (!shouldSave || !mounted) return;

    // ── Save to DB ────────────────────────────────────────────────────────
    // Re-capture nav (may still be same, but safe after another async gap)
    final nav2       = Navigator.of(context);
    final messenger2 = ScaffoldMessenger.of(context);
    showPremiumLoading(context, message: 'Saving location...');
    try {
      await _db.updateCustomerLocation(
        lcoCustomerId: _customer.lcoCustomerId,
        areaName: areaName,
        latitude: lat,
        longitude: lng,
      );
      if (!mounted) return;
      nav2.pop();
      messenger2.showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Location saved successfully', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      setState(() {
        _customer = _customer.copyWith(areaName: areaName, latitude: lat, longitude: lng);
      });
    } catch (e) {
      if (mounted) {
        nav2.pop();
        messenger2.showSnackBar(SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  Future<void> _openCustomerMap() async {
    if (_customer.latitude == null || _customer.longitude == null) {
      showPremiumSnackBar(context, 'Update customer location first', isError: true);
      return;
    }
    // Capture navigator before async gap
    final nav = Navigator.of(context);
    showPremiumLoading(context, message: 'Getting your location...');
    try {
      final current = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      nav.pop();
      nav.push(
        MaterialPageRoute(
          builder: (_) => CustomerMapScreen(
            customer: _customer,
            currentLocation: LatLng(current.latitude, current.longitude),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        nav.pop();
        showPremiumSnackBar(context, 'Location error: $e', isError: true);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final AppThemeConst t;
  const _WhiteCard({required this.child, required this.t});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: t.cardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: t.cardShadowColor,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}

class _Op {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  const _Op(this.icon, this.label, this.gradientColors);
}

class _OpItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final AppThemeConst t;
  final VoidCallback onTap;

  const _OpItem({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.t,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.30),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: gradientColors.first,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}