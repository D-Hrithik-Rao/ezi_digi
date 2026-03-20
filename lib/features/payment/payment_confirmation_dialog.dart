import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
      setState(() {
        _currentMonthPayments = paymentCount;
        _currentMonthAdjustments = 0; // You can implement adjustment logic if needed
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingL),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else ...[
              _buildPaymentInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildConfirmationMessage(),
              const SizedBox(height: AppSizes.paddingL),
              _buildButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Payment Confirmation',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          _infoRow('Last Paid Amount', widget.customer.pendingAmount),
          _infoRow('Last Paid Date', widget.customer.lastPaidDate),
          _infoRow('Current Month Payments Count', _currentMonthPayments.toString()),
          _infoRow('Current Month Adjustments Count', _currentMonthAdjustments.toString()),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.info_circle,
            color: Colors.blue.shade600,
            size: 32,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Are you sure you want to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Digital TV Payment ₹${widget.amount.toStringAsFixed(1)}?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
            child: const Text(
              'CONFIRM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
