import 'package:flutter/material.dart';

import '../../core/theme/theme_constants.dart';

class SearchCollectionsScreen extends StatefulWidget {
  const SearchCollectionsScreen({super.key});

  @override
  State<SearchCollectionsScreen> createState() => _SearchCollectionsScreenState();
}

class _SearchCollectionsScreenState extends State<SearchCollectionsScreen> {
  DateTime _startDate = DateTime(2026, 3, 30);
  DateTime _endDate   = DateTime(2026, 3, 30);

  String _fmt(DateTime d) => '${d.day}-${d.month}-${d.year}';

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) _startDate = picked;
      else          _endDate   = picked;
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
              color: t.backBtnBg, borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: t.backBtnIcon),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SEARCH COLLECTIONS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              letterSpacing: 1.0, color: t.appBarFg),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Date range card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.cardBg,
                borderRadius: t.cardBorderRadius,
                boxShadow: [
                  BoxShadow(color: t.cardShadowColor, blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildDateRow(context, 'Start Date', _fmt(_startDate), true, t),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: t.dividerColor),
                  const SizedBox(height: 16),
                  _buildDateRow(context, 'End Date', _fmt(_endDate), false, t),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Search button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Searching collections...')),
                  );
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, String title, String value,
      bool isStart, AppThemeConst t) {
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.cardHeadingText)),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.cardBodyText)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: t.accent, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}