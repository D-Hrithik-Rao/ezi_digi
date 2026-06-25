import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCAN CUSTOMER SCREEN — real MobileScanner with camera permission
// Matches the reference photo layout exactly.
// ─────────────────────────────────────────────────────────────────────────────
class ScanCustomerScreen extends StatefulWidget {
  const ScanCustomerScreen({super.key});

  @override
  State<ScanCustomerScreen> createState() => _ScanCustomerScreenState();
}

class _ScanCustomerScreenState extends State<ScanCustomerScreen> {
  String _selectedType = 'Serial Number';
  static const List<String> _types = ['Serial Number', 'VC Number'];

  String _scannedValue = '';
  bool _permissionGranted = false;
  bool _checkingPermission = true;
  MobileScannerController? _scanCtrl;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      _scanCtrl = MobileScannerController(
        formats: [BarcodeFormat.all],
        autoStart: true,
      );
      setState(() {
        _permissionGranted = true;
        _checkingPermission = false;
      });
    } else {
      setState(() {
        _permissionGranted = false;
        _checkingPermission = false;
      });
    }
  }

  @override
  void dispose() {
    _scanCtrl?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw != null && raw.isNotEmpty && _scannedValue.isEmpty) {
      _scanCtrl?.stop();
      setState(() => _scannedValue = raw);
    }
  }

  void _resetScan() {
    setState(() => _scannedValue = '');
    _scanCtrl?.start();
  }

  void _search() {
    if (_scannedValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barcode scanned yet')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Search Result'),
        content: Text('Customer found for:\n$_scannedValue'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
        ),
        title: const Text(
          'SEARCH CUSTOMER WITH SCAN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: _checkingPermission
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Requesting camera permission...',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  // ── Type Dropdown ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.primary),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        items: _types
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Camera Preview ───────────────────────────────────────
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _permissionGranted
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                MobileScanner(
                                  controller: _scanCtrl,
                                  onDetect: _onDetect,
                                ),
                                // Corner scan frame overlay
                                Positioned.fill(
                                  child: CustomPaint(painter: _ScannerFramePainter()),
                                ),
                              ],
                            )
                          : _buildPermissionDenied(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Result Box ───────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _scannedValue.isEmpty
                                ? 'No Barcode detected'
                                : _scannedValue,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _scannedValue.isEmpty
                                  ? AppColors.primary.withValues(alpha: 0.45)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (_scannedValue.isNotEmpty)
                          GestureDetector(
                            onTap: _resetScan,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.refresh_rounded,
                                  color: AppColors.primary, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── SEARCH button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'SEARCH',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_rounded, color: Colors.white60, size: 52),
          const SizedBox(height: 16),
          const Text(
            'Camera permission is required\nto scan barcodes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: openAppSettings,
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanner corner frame overlay — draws 4 corner brackets
// ─────────────────────────────────────────────────────────────────────────────
class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const inset = 32.0;
    const len = 28.0;
    final x1 = inset;
    final y1 = inset;
    final x2 = size.width - inset;
    final y2 = size.height - inset;

    // Top-left
    canvas.drawLine(Offset(x1, y1), Offset(x1 + len, y1), paint);
    canvas.drawLine(Offset(x1, y1), Offset(x1, y1 + len), paint);
    // Top-right
    canvas.drawLine(Offset(x2, y1), Offset(x2 - len, y1), paint);
    canvas.drawLine(Offset(x2, y1), Offset(x2, y1 + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(x1, y2), Offset(x1 + len, y2), paint);
    canvas.drawLine(Offset(x1, y2), Offset(x1, y2 - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(x2, y2), Offset(x2 - len, y2), paint);
    canvas.drawLine(Offset(x2, y2), Offset(x2, y2 - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}