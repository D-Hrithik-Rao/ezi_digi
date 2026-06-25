import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final Customer customer;
  final double amount;
  final String paymentMethod;

  const PaymentConfirmationDialog({
    super.key,
    required this.customer,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentMonthPayments = 0;
  int _currentMonthAdjustments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentStats();
  }

  Future<void> _loadPaymentStats() async {
    try {
      final paymentCount = await _dbHelper.getCurrentMonthPaymentCount(widget.customer.lcoCustomerId);
      if (mounted) {
        setState(() {
          _currentMonthPayments = paymentCount;
          _currentMonthAdjustments = 0; // You can implement adjustment logic if needed
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title ──
            const Text(
              'Payment Confirmation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // ── Info Rows ──
              _infoRow('Last Paid Amount', widget.customer.pendingAmount.isEmpty ? '₹0.0' : widget.customer.pendingAmount),
              _infoRow('Last Paid Date', widget.customer.lastPaidDate.isEmpty ? 'Code=0' : widget.customer.lastPaidDate),
              _infoRow('Current Month\nPayments Count', _currentMonthPayments.toString()),
              _infoRow('Current Month\nAdjustments Count', _currentMonthAdjustments.toString()),
              
              const SizedBox(height: 20),

              // ── Confirmation Prompt ──
              Text(
                'Are you sure you want to continue Digital TV\nPayment ₹${widget.amount.toStringAsFixed(1)}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // ── Action Buttons ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC60000), // Red
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2), // Sharp corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('CANCEL',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333399), // Navy Blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2), // Sharp corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('CONFIRM',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
