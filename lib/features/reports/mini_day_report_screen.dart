import 'package:ezi_cable_digi/core/services/localization_service.dart';
import 'package:flutter/material.dart';

import '../../core/theme/theme_constants.dart';

class MiniDayReportScreen extends StatelessWidget {
  const MiniDayReportScreen({super.key});

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
          AppStrings.of(context, 'mini_day_report').toUpperCase(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
              letterSpacing: 1.1, color: t.appBarFg),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Print button row ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: t.sectionBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.print, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.of(context, 'print'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: t.bodyText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Data card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: t.cardBg,
                borderRadius: t.cardBorderRadius,
                boxShadow: [
                  BoxShadow(color: t.cardShadowColor, blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.of(context, 'mode'),
                          style: TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 13, color: t.cardHeadingText)),
                      Text(AppStrings.of(context, 'count'),
                          style: TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 13, color: t.cardHeadingText)),
                      Text(AppStrings.of(context, 'amount'),
                          style: TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 13, color: t.cardHeadingText)),
                    ],
                  ),

                  Divider(height: 20, color: t.dividerColor),

                  // Cash row
                  _ReportRow(
                    label: AppStrings.of(context, 'cash_stb'),
                    count: '0', amount: '0.0', t: t,
                  ),

                  const SizedBox(height: 10),

                  // Bank row
                  _ReportRow(
                    label: AppStrings.of(context, 'bank_stb'),
                    count: '0', amount: '0.0', t: t,
                  ),

                  Divider(height: 20, color: t.dividerColor),

                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.of(context, 'total_collection'),
                        style: TextStyle(fontWeight: FontWeight.w800,
                            fontSize: 14, color: t.accent),
                      ),
                      Text(
                        '₹0.0',
                        style: TextStyle(fontWeight: FontWeight.w800,
                            fontSize: 14, color: t.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String count;
  final String amount;
  final AppThemeConst t;

  const _ReportRow({
    required this.label,
    required this.count,
    required this.amount,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: t.cardBodyText, fontWeight: FontWeight.w600)),
        Text(count,  style: TextStyle(fontSize: 13, color: t.cardBodyText, fontWeight: FontWeight.w600)),
        Text(amount, style: TextStyle(fontSize: 13, color: t.cardBodyText, fontWeight: FontWeight.w600)),
      ],
    );
  }
}