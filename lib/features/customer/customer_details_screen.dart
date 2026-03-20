import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../payment/payment_options_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CUSTOMER DETAILS'),
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
              _buildLocationInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildCustomerOperations(context),
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
          _detailRow('Customer Name', customer.name),
          _detailRow('Nick Name', customer.nickName),
          _detailRow('Mobile Number', customer.primaryMobileNumber),
          _detailRow('Total Due', customer.totalDue),
          _detailRow('Amount Payable', customer.amountPayable),
          _detailRow('Customer Type', customer.customerType),
          _detailRow('Group Name', customer.groupName),
          _detailRow('Area Name', customer.areaName),
          _detailRow('Address', customer.address),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('LOCATION'),
          const SizedBox(height: AppSizes.paddingM),
          _detailRow('Last Paid Date', customer.lastPaidDate),
          _detailRow('Bill Month', customer.billMonth),
          _detailRow('LCO Customer id', customer.lcoCustomerId),
          _detailRow('Box Number', customer.boxNumber),
          _detailRow('VC Number', customer.vcNumber),
        ],
      ),
    );
  }

  Widget _buildCustomerOperations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CUSTOMER OPERATIONS'),
          const SizedBox(height: AppSizes.paddingM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: AppSizes.paddingS,
            crossAxisSpacing: AppSizes.paddingS,
            children: [
              _operationItem(Iconsax.money_send, 'Make Payments', context),
              _operationItem(Iconsax.clock, 'Payment History', context),
              _operationItem(Iconsax.message_question, 'Create Complaints', context),
              _operationItem(Iconsax.location, 'Update Location', context),
              _operationItem(Iconsax.document, 'Invoice History', context),
              _operationItem(Iconsax.message_text, 'Complaint History', context),
              _operationItem(Iconsax.box, 'Package Operations', context),
              _operationItem(Icons.tv, 'Deactivate STB', context),
              _operationItem(Iconsax.chart, 'Act-Deact Report', context),
              _operationItem(Iconsax.money_add, 'One Time Charges', context),
              _operationItem(Iconsax.clock1, 'One Time History', context),
              _operationItem(Iconsax.wallet_money, 'Pay Later', context),
            ],
          ),
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (label == 'Mobile Number' || label == 'LCO Customer id')
                  const Icon(Iconsax.edit, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _operationItem(IconData icon, String label, BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'Make Payments') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentOptionsScreen(customer: customer),
            ),
          );
        } else {
          // Handle other operations
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
