import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import 'payment_confirmation_dialog.dart';
import 'payment_details_screen.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final Customer customer;

  const PaymentOptionsScreen({super.key, required this.customer});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  final _amountController = TextEditingController();
  final _mobileController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _sendSms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAYMENT OPTIONS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.primary,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildPaymentForm(),
              const SizedBox(height: AppSizes.paddingL),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CUSTOMER INFO'),
          const SizedBox(height: AppSizes.paddingM),
          _detailRow('Customer Name', widget.customer.name),
          _detailRow('Mobile Number', widget.customer.primaryMobileNumber),
          _detailRow('Total Due', widget.customer.totalDue),
          _detailRow('Amount Payable(STB)', widget.customer.amountPayable),
          _detailRow('Customer Type', widget.customer.customerType),
          _detailRow('Last Paid Date', widget.customer.lastPaidDate),
          _detailRow('Bill Month', widget.customer.billMonth),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PAYMENT DETAILS'),
          const SizedBox(height: AppSizes.paddingM),
          _amountInput(),
          const SizedBox(height: AppSizes.paddingM),
          _paymentMethodSelector(),
          const SizedBox(height: AppSizes.paddingM),
          _mobileInput(),
          const SizedBox(height: AppSizes.paddingS),
          _smsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
            flex: 3,
            child: Text(
              value,
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

  Widget _amountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter Amount',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _paymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'cash'),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'cash' ? AppColors.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Text(
                    'Cash',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _paymentMethod == 'cash' ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'bank'),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'bank' ? AppColors.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Text(
                    'Bank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _paymentMethod == 'bank' ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mobileInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _mobileController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Mobile Number (Optional)',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _smsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _sendSms,
          onChanged: (value) => setState(() => _sendSms = value ?? false),
          activeColor: AppColors.primary,
        ),
        const Text(
          'Send SMS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _handlePay,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
      child: const Text(
        'PAY',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _handlePay() async {
    if (_amountController.text.isEmpty) {
      _showError('Please enter amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter valid amount');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PaymentConfirmationDialog(
        customer: widget.customer,
        amount: amount,
        paymentMethod: _paymentMethod,
      ),
    );

    if (confirmed == true) {
      // Navigate to payment details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailsScreen(
            customer: widget.customer,
            amount: amount,
            paymentMethod: _paymentMethod,
            mobileNumber: _mobileController.text.isEmpty ? widget.customer.primaryMobileNumber : _mobileController.text,
            sendSms: _sendSms,
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
