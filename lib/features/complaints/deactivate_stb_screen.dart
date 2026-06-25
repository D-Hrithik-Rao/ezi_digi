import 'package:flutter/material.dart';
import '../../../core/data/customer.dart';

class DeactivateStbScreen extends StatefulWidget {
  final Customer customer;
  const DeactivateStbScreen({super.key, required this.customer});

  @override
  State<DeactivateStbScreen> createState() => _DeactivateStbScreenState();
}

class _DeactivateStbScreenState extends State<DeactivateStbScreen> {
  String? _selectedSerial;
  String? _selectedReason;

  final _reasons = [
    'Choose Reason',
    'Unpaid Customer',
    'Temporary Deactivation1',
    'Others',
    'On Vacation',
    'On Hold',
    'Deactivation Package Change',
  ];

  void _submit() {
    if (_selectedSerial == null) {
      _snack('Please select STB');
      return;
    }
    if (_selectedReason == null || _selectedReason == 'Choose Reason') {
      _snack('Please select a reason');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate STB',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Deactivate $_selectedSerial with reason "$_selectedReason"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('STB Deactivated Successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('YES', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serials = [widget.customer.serialNumber, widget.customer.boxNumber]
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Please select STB
              Row(
                children: [
                  const Expanded(
                    child: Text('Please select STB',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D47A1))),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSerial,
                      hint: const Text('Select'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: serials
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSerial = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Please select a reason
              Row(
                children: [
                  const Expanded(
                    child: Text('Please select a reason',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D47A1))),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedReason,
                      hint: const Text('Select'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _reasons
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedReason = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('DEACTIVATE',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 0,
      centerTitle: true,
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
      title: const Text('DEACTIVATE STB',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
    );
  }
}