import 'package:ezi_cable_digi/bluetooth/bluetooth_devices_screen.dart';
import 'package:ezi_cable_digi/core/services/localization_service.dart';
import 'package:ezi_cable_digi/features/event/event_management_screen.dart';
import 'package:ezi_cable_digi/features/offline/offline_dashboard_screen.dart';
import 'package:ezi_cable_digi/features/offline/download_records_screen.dart';
import 'package:ezi_cable_digi/features/reports/mini_day_report_screen.dart';
import 'package:ezi_cable_digi/features/reports/search_collections_screen.dart';
import 'package:ezi_cable_digi/features/scan/scan_customer_screen.dart';
import 'package:ezi_cable_digi/features/search/search_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import '../complaints/complaints_screen.dart';
import '../complaints/complaint_details_screen.dart';
import '../analytics/analytics_screen.dart';
import '../expenses/add_expenses_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_sync_service.dart';
import '../../main.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../customers/customer_list_screen.dart';
import '../../features/settings/printer_settings_screen.dart';

enum _FeedType { complaints, unpaid, nearest, payLater }

enum _TicketStatus { assigned, inprocess }

class _TicketItem {
  final String ticketId;
  final String name;
  final String description;
  final String customerId;
  final _TicketStatus status;

  const _TicketItem({
    required this.ticketId,
    required this.name,
    required this.description,
    required this.customerId,
    required this.status,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  Widget _getScreen() {
    if (_selectedTab == 1) return const ComplaintsScreen();
    if (_selectedTab == 2) return const AnalyticsScreen();
    if (_selectedTab == 3) return const AddExpensesScreen();
    return const SizedBox();
  }

  int _selectedTab = 0;
  _FeedType _feed = _FeedType.complaints;

  // ── Dummy data — replace with real API / DB calls ─────────────────────────
  final List<_TicketItem> _complaints = const [
    _TicketItem(
      ticketId: 'CTS/116696/485/251030122316',
      name: 'Shaker',
      description: 'Description : payment issue',
      customerId: 'SH_08',
      status: _TicketStatus.assigned,
    ),
    _TicketItem(
      ticketId: 'CTS/116699/485/251017161847',
      name: 'Amol',
      description: 'Description : Box Missing',
      customerId: 'Am_11',
      status: _TicketStatus.inprocess,
    ),
  ];

  final List<_TicketItem> _unpaid = const [
    _TicketItem(
      ticketId: 'UPD/0007',
      name: 'Customer One Twentyseven',
      description: 'Pending amount ₹ 1,411.00',
      customerId: 'LCO-0007',
      status: _TicketStatus.assigned,
    ),
    _TicketItem(
      ticketId: 'UPD/0002',
      name: 'Customer Two',
      description: 'Pending amount ₹ 589.00',
      customerId: 'LCO-0002',
      status: _TicketStatus.inprocess,
    ),
  ];

  final List<_TicketItem> _nearest = const [
    _TicketItem(
      ticketId: 'NEAR/0011',
      name: 'Shaker',
      description: 'Distance : 0.8 km',
      customerId: 'LCO-SH_08',
      status: _TicketStatus.assigned,
    ),
    _TicketItem(
      ticketId: 'NEAR/0013',
      name: 'Amol',
      description: 'Distance : 1.9 km',
      customerId: 'LCO-AM_11',
      status: _TicketStatus.inprocess,
    ),
  ];

  final List<_TicketItem> _payLater = const [
    _TicketItem(
      ticketId: 'PL/1020',
      name: 'Pay Later Customer',
      description: 'Installment pending (next due soon)',
      customerId: 'PL-01',
      status: _TicketStatus.assigned,
    ),
    _TicketItem(
      ticketId: 'PL/1017',
      name: 'Pay Later Customer',
      description: 'Installment in progress',
      customerId: 'PL-02',
      status: _TicketStatus.inprocess,
    ),
  ];

  List<_TicketItem> get _currentFeed => switch (_feed) {
    _FeedType.complaints => _complaints,
    _FeedType.unpaid => _unpaid,
    _FeedType.nearest => _nearest,
    _FeedType.payLater => _payLater,
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    LocationSyncService.instance.onScreenOpened(TrackingScreen.dashboard);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    LocationSyncService.instance.stopDashboardTracking();
    super.dispose();
  }

  @override
  void didPushNext() =>
      LocationSyncService.instance.onScreenOpened(TrackingScreen.other);

  @override
  void didPopNext() =>
      LocationSyncService.instance.onScreenOpened(TrackingScreen.dashboard);

  // ── Build ──────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: _PremiumAppBar(),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedTab,
        onChanged: (i) => setState(() => _selectedTab = i),
      ),
      body: _selectedTab == 0
          ? Container(
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── itp label ─────────────────────────────────────────────────
                    const Text(
                      'itp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Row 1: 3 Gradient Summary Cards ───────────────────────────
                    // Due Amount  → deep blue-to-sky  
                    // Month Billing → rose-to-pink    
                    // Onetime Ch…  → amber-to-orange  
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _GradientSummaryCard(
                              title: AppStrings.of(context, 'due_amount'),
                              amount: '₹0.00',
                              subtitle: '120 customers',
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB91C1C),
                                  Color(0xFFEF4444),
                                  Color(0xFFFB7185),
                                ],
                                stops: [0.0, 0.55, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              icon: Iconsax.receipt_item,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _GradientSummaryCard(
                              title: AppStrings.of(context, 'month_billing'),
                              amount: '₹0.00',
                              subtitle: AppStrings.of(context, 'this_month'),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEA580C),
                                  Color(0xFFF97316),
                                  Color(0xFFFBBF24),
                                ],
                                stops: [0.0, 0.5, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              icon: Iconsax.calendar_tick,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _GradientSummaryCard(
                              title: AppStrings.of(context, 'onetime_charges'),
                              amount: '₹250.00',
                              subtitle: AppStrings.of(context, 'installations'),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0277BD),
                                  Color(0xFF0288D1),
                                  Color(0xFF26C6DA),
                                ],
                                stops: [0.0, 0.45, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              icon: Iconsax.flash_circle,
                              useDarkText: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Row 2: LCO Wallet + Collections ───────────────────────────
                    // LCO Wallet  → green-to-cyan  (existing — premium mixing)
                    // Collections → purple-to-violet matching the same diagonal style
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _LottieHighlightCard(
                              title: AppStrings.of(context, 'lco_wallet'),
                              amount: '₹0.0',
                              subtitle: AppStrings.of(context, 'available'),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF0EA5E9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              lottieAsset: 'assets/Wallet Animation.json',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LottieHighlightCard(
                              title: AppStrings.of(context, 'collections'),
                              amount: '₹750.00',
                              subtitle: AppStrings.of(context, 'today'),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEC4899),
                                  Color(0xFF8B5CF6),
                                  Color(0xFF4F46E5),
                                ],
                                stops: [0.0, 0.5, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              lottieAsset: 'assets/Growth Chart.json',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Row 3: Quick Actions — horizontal scroll ───────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FF),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _QuickActionTile(
                              icon: Iconsax.user_tag,
                              label: AppStrings.of(context, 'customer_list'),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CustomerListScreen(),
                                ),
                              ),
                            ),
                            _QuickActionTile(
                              icon: Iconsax.document_download,
                              label: AppStrings.of(context, 'download_data_btn'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DownloadRecordsScreen(),
                                ),
                              ),
                            ),
                            _QuickActionTile(
                              icon: Iconsax.search_status,
                              label: AppStrings.of(context, 'offline_search'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OfflineDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                            _QuickActionTile(
                              icon: Iconsax.calendar_1,
                              label: AppStrings.of(context, 'miniday_report_btn'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MiniDayReportScreen(),
                                  ),
                                );
                              },
                            ),
                            _QuickActionTile(
                              icon: Iconsax.chart_2,
                              label: AppStrings.of(context, 'monthly_report_btn'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SearchCollectionsScreen(),
                                  ),
                                );
                              },
                            ),
                            _QuickActionTile(
                              icon: Iconsax.setting_2,
                              label: AppStrings.of(context, 'settings_btn'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PrinterSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── White card: filter chips + feed list ───────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _FeedChip(
                                    label: AppStrings.of(context, 'complaints'),
                                    selected: _feed == _FeedType.complaints,
                                    onTap: () => setState(
                                      () => _feed = _FeedType.complaints,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _FeedChip(
                                    label: AppStrings.of(context, 'unpaid'),
                                    selected: _feed == _FeedType.unpaid,
                                    onTap: () => setState(
                                      () => _feed = _FeedType.unpaid,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _FeedChip(
                                    label: AppStrings.of(context, 'nearest'),
                                    selected: _feed == _FeedType.nearest,
                                    onTap: () => setState(
                                      () => _feed = _FeedType.nearest,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _FeedChip(
                                    label: AppStrings.of(context, 'pay_later'),
                                    selected: _feed == _FeedType.payLater,
                                    onTap: () => setState(
                                      () => _feed = _FeedType.payLater,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 0.6,
                            indent: 12,
                            endIndent: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                            child: ListView.builder(
                              itemCount: _currentFeed.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, i) => _TicketCard(
                                item: _currentFeed[i],
                                isLast: i == _currentFeed.length - 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _getScreen(),
    );
  }

  void _snack(String label) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$label (coming soon)')));
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Summary Card (Due Amount / Month Billing / Onetime Charges)
// [useDarkText] → true for light-coloured gradients (amber/yellow)
// ─────────────────────────────────────────────────────────────────────────────
class _GradientSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final bool useDarkText;
  const _GradientSummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.useDarkText = false,
  });
  @override
  Widget build(BuildContext context) {
    final Color base = useDarkText
        ? Colors.black.withValues(alpha: 0.75)
        : Colors.white;
    final Color muted = useDarkText
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.80);
    final Color dim = useDarkText
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.white.withValues(alpha: 0.70);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 9, 6, 9),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: muted, size: 15),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: muted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: base,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: dim,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lottie Highlight Card (LCO Wallet / Collections)
// ─────────────────────────────────────────────────────────────────────────────
class _LottieHighlightCard extends StatefulWidget {
  final String title;
  final String amount;
  final String subtitle;
  final LinearGradient gradient;
  final String lottieAsset;

  const _LottieHighlightCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.gradient,
    required this.lottieAsset,
  });

  @override
  State<_LottieHighlightCard> createState() => _LottieHighlightCardState();
}

class _LottieHighlightCardState extends State<_LottieHighlightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _replay,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.amount,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 48,
              height: 48,
              child: Lottie.asset(
                widget.lottieAsset,
                controller: _controller,
                fit: BoxFit.contain,
                repeat: false,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward(); // play once on load
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Action Tile
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Intrinsic width — no hard fixed width so text fits in one line
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          // Same premium frosted-light card as reference — white bg, soft shadow
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feed Filter Chip
// ─────────────────────────────────────────────────────────────────────────────
class _FeedChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FeedChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 13, color: AppColors.primary),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary : Colors.black54,
              ),
            ),
            if (!selected)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Card 
// ─────────────────────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final _TicketItem item;
  final bool isLast;

  const _TicketCard({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isAssigned = item.status == _TicketStatus.assigned;
    final statusColor = isAssigned
        ? AppColors.success
        : const Color(0xFFF59E0B);
    final statusText = isAssigned ? 'ASSIGNED' : 'INPROCESS';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar with ticket ID + location icon
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.ticketId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    /* TODO: open map navigation */
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Iconsax.location,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Name : ${item.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        'Status : $statusText',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'LCO Customer ID : ${item.customerId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Full-width Update Status button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailsScreen(
                            complaintId: item.ticketId,
                            customerName: item.name,
                            complaint: item.description,
                            currentStatus: item.status == _TicketStatus.assigned
                                ? 'ASSIGNED'
                                : 'INPROCESS',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    label: Text(AppStrings.get('update_status')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium AppBar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumAppBar extends StatelessWidget {
  const _PremiumAppBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                // ── Hamburger — white pill, premium exclusive touch ────────
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Iconsax.menu_1,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                // ── Logo centred ───────────────────────────────────────────
                const SizedBox(width: 8.0),
                const Spacer(),
                Image.asset(
                  'assets/ezy_digi_pics.png',
                  height: 42,
                
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                // ── Action icons with pill containers ────────────────────
                _AppBarIcon(
                  icon: Iconsax.search_normal,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchCustomerScreen()),
                  ),
                ),
                const SizedBox(width: 4),
                _AppBarIcon(
                  icon: Iconsax.bluetooth,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BluetoothDevicesScreen()),
                  ),
                ),
                const SizedBox(width: 4),
                _AppBarIcon(
                  icon: Iconsax.calendar,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventManagementScreen()),
                  ),
                ),
                const SizedBox(width: 4),
                _AppBarIcon(
                  icon: Iconsax.scan_barcode,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanCustomerScreen()),
                  ),
                ),
                const SizedBox(width: 4),
                // ── Language switcher ──────────────────────────────────────
                _AppBarIcon(
                  icon: Icons.language_rounded,
                  onTap: () => showLanguagePicker(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppBarIcon — small icon with translucent rounded pill container
// ─────────────────────────────────────────────────────────────────────────────
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 0.8,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
