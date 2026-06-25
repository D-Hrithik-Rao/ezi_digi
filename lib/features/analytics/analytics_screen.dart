import 'dart:math';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  final double outstanding = 390000;
  final double collection = 44339;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurveTween(curve: Curves.easeOutCubic).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = outstanding + collection;
    final double outPct = total == 0 ? 0 : outstanding / total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Analytics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFDCE2F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Doughnut Chart
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: _DoughnutChartPainter(
                            progress: _anim.value,
                            outstandingPct: outPct,
                          ),
                        ),
                      ),
                      // Center Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${outstanding.toInt()}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB52B4D), // Maroon
                            ),
                          ),
                          const Text(
                            "Outstanding",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "₹${collection.toInt()}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF8A65), // Orange
                            ),
                          ),
                          const Text(
                            "Collection",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: const Color(0xFFB52B4D), label: 'Outstanding'),
                const SizedBox(width: 16),
                _LegendItem(color: const Color(0xFFFF8A65), label: 'Collection'),
                const SizedBox(width: 16),
                const Text(
                  'Collections Data',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}

class _DoughnutChartPainter extends CustomPainter {
  final double progress;
  final double outstandingPct;

  _DoughnutChartPainter({required this.progress, required this.outstandingPct});

  @override
  void paint(Canvas canvas, Size size) {
    final double sweepAngle = 2 * pi * progress;
    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final strokeWidth = 50.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final outPaint = Paint()
      ..color = const Color(0xFFB52B4D) // Maroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final colPaint = Paint()
      ..color = const Color(0xFFFF8A65) // Orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Start from top (-pi / 2)
    final startAngle = -pi / 2;

    // Draw outstanding portion
    final outSweep = sweepAngle * outstandingPct;
    canvas.drawArc(rect, startAngle, outSweep, false, outPaint);

    // Draw collection portion
    final colSweep = sweepAngle * (1 - outstandingPct);
    canvas.drawArc(rect, startAngle + outSweep, colSweep, false, colPaint);
  }

  @override
  bool shouldRepaint(covariant _DoughnutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.outstandingPct != outstandingPct;
  }
}