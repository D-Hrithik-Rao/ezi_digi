import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/theme_constants.dart';
import '../customer/customer_details_screen.dart';
import '../customer/customer_map_screen.dart';
import 'search_provider.dart';

class SearchCustomerScreen extends StatefulWidget {
  const SearchCustomerScreen({super.key});
  @override
  State<SearchCustomerScreen> createState() => _SearchCustomerScreenState();
}

class _SearchCustomerScreenState extends State<SearchCustomerScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode        = FocusNode();
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    DatabaseHelper().insertDemoData().catchError((_) {});

    // Clear previous search results exactly as requested when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SearchProvider>().clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    _focusNode.unfocus();
    await context.read<SearchProvider>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: _appBar(t),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Teal gradient banner ──────────────────────────────────────
              _headerChip(t),
              const SizedBox(height: 14),
              // ── Dropdown ─────────────────────────────────────────────────
              _dropdown(t),
              const SizedBox(height: 10),
              // ── Search field ─────────────────────────────────────────────
              _searchField(t),
              const SizedBox(height: 14),
              // ── Results ──────────────────────────────────────────────────
              Consumer<SearchProvider>(
                builder: (context, p, _) {
                  if (p.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator(color: t.accent)),
                    );
                  }
                  if (p.error != null) {
                    return _empty(p.error!, Iconsax.warning_2, t);
                  }
                  if (!p.hasSearched) return const SizedBox.shrink();
                  if (p.results.isEmpty) return _empty('No customers found', Iconsax.user_search, t);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _resultBanner(p, t),
                      const SizedBox(height: 10),
                      ...p.results.map((c) => _CustomerCard(customer: c, t: t)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar(AppThemeConst t) => AppBar(
        backgroundColor: t.appBarBg,
        foregroundColor: t.appBarFg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: t.backBtnBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: t.backBtnIcon),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SEARCH CUSTOMER',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                letterSpacing: 1.2, color: t.appBarFg)),
      );

  // ── Teal gradient banner chip ─────────────────────────────────────────────
  Widget _headerChip(AppThemeConst t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: t.headerGradient,
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.search_normal, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('SEARCH CUSTOMER',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 14, letterSpacing: 0.6)),
          ],
        ),
      );

  // ── Criteria dropdown ─────────────────────────────────────────────────────
  Widget _dropdown(AppThemeConst t) => Consumer<SearchProvider>(
        builder: (context, p, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: p.criteria,
              isExpanded: true,
              menuMaxHeight: 320,
              icon: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: Colors.black54),
              ),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D1B4B), fontSize: 15),
              items: SearchProvider.criteriaItems
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(e,
                              style: const TextStyle(fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D1B4B), fontSize: 14)),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                context.read<SearchProvider>().setCriteria(v);
                _searchController.clear();
              },
            ),
          ),
        ),
      );

  // ── Search field ──────────────────────────────────────────────────────────
  Widget _searchField(AppThemeConst t) => Consumer<SearchProvider>(
        builder: (context, p, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0D1B4B)),
                  decoration: InputDecoration(
                    hintText: p.hintText,
                    hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w400, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: GestureDetector(
                  onTap: _performSearch,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.search_normal, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // ── Results count banner ──────────────────────────────────────────────────
  Widget _resultBanner(SearchProvider p, AppThemeConst t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: t.headerGradient,
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text('RESULTS BY ${p.criteria}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 13, letterSpacing: 0.3)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${p.results.length} found',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _empty(String msg, IconData icon, AppThemeConst t) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(icon, size: 52, color: t.emptyStateIconColor),
            const SizedBox(height: 12),
            Text(msg, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.bodyText)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CustomerCard — matches reference photo exactly
//   • Light blue-grey card bg (#F0F4FF)
//   • Blue rounded-square avatar
//   • Outlined STB badge
//   • Icon info rows (Pending, Last Paid, Address)
//   • Dark navy "View Details" button + red map pin
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final AppThemeConst t;
  const _CustomerCard({required this.customer, required this.t});

  @override
  Widget build(BuildContext context) {
    final hasLoc    = customer.latitude != null && customer.longitude != null;
    final hasPending = customer.pendingAmount.isNotEmpty &&
        customer.pendingAmount != '₹0' && customer.pendingAmount != '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, // Bottom part is white
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header row (Light Blue-Grey Background) ──────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7FF), // Exact match to reference photo light header
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Blue gradient rounded-square avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: t.headerGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + sub-id
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: Color(0xFF0D1B4B))),
                      if (customer.altCustomerId.isNotEmpty)
                        Text(customer.altCustomerId,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500,
                                color: Colors.black54)),
                    ],
                  ),
                ),
                // STB softly colored badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6), // Soft indigo/grey tint
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC5CAE9)), // Subtle border
                  ),
                  child: Text(customer.customerType,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: Color(0xFF3F51B5))), // Indigo text
                ),
              ],
            ),
          ),

          // ── Info & Buttons Section (Pure White Background) ───────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info rows
                _row(Iconsax.timer_1, 'Pending Amount',
                    customer.pendingAmount.isEmpty ? '₹0' : customer.pendingAmount,
                    valueColor: hasPending ? const Color(0xFFD32F2F) : const Color(0xFF1AA95A)),
                const SizedBox(height: 8),
                _row(Iconsax.calendar_tick, 'Last Paid Date',
                    customer.lastPaidDate.isEmpty ? '—' : customer.lastPaidDate),
                const SizedBox(height: 8),
                _row(Iconsax.home, 'Address',
                    customer.address.isEmpty ? '—' : customer.address),

                const SizedBox(height: 14),

                // Buttons
                Row(
                  children: [
                    // Dark navy "View Details" button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CustomerDetailsScreen(customer: customer))),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A8C),   // dark navy — reference photo
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.user_tag, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('View Details',
                                  style: TextStyle(color: Colors.white, fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Red/pink map pin — only if GPS saved
                    if (hasLoc) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CustomerMapScreen(
                                  customer: customer,
                                  currentLocation: LatLng(customer.latitude!, customer.longitude!),
                                ))),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.location,
                              color: Color(0xFFD32F2F), size: 22),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF5B7BCC)),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: Colors.black54, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF0D1B4B),
              )),
        ),
      ],
    );
  }
}