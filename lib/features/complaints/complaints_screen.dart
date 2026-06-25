import 'package:flutter/material.dart';
import '../../core/theme/theme_constants.dart';
import '../../features/dashboard/widgets/complaint_card.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

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
          'OPEN COMPLAINTS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
              letterSpacing: 1.1, color: t.appBarFg),
        ),
      ),
      body: Column(
        children: [
          // ── Dealer filter ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: t.cardShadowColor, blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Choose',
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: t.accent),
                items: const [
                  DropdownMenuItem(value: 'Choose', child: Text('Choose')),
                  DropdownMenuItem(value: 'itp',    child: Text('itp')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),

          // ── Count badge ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.accent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Total: 8',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: t.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Complaint list ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                ComplaintCard(
                  complaintId: 'CTS/116696/485/251030122316',
                  name: 'Shaker',
                  description: 'payment issue',
                  status: ComplaintStatus.assigned,
                ),
                ComplaintCard(
                  complaintId: 'CTS/116699/485/251017161847',
                  name: 'Amol',
                  description: 'Box Missing',
                  status: ComplaintStatus.inProcess,
                ),
                ComplaintCard(
                  complaintId: 'CTS/116702/485/251016220856',
                  name: 'Narshmi',
                  description: 'Box Missing',
                  status: ComplaintStatus.inProcess,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}