import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _header1 = TextEditingController();
  final _header2 = TextEditingController();
  final _footer1 = TextEditingController();
  final _footer2 = TextEditingController();
  final _amountFilter = TextEditingController(text: '500.0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRINTER SETTINGS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _textField('Header 1', _header1),
                    const SizedBox(height: AppSizes.paddingS),
                    _textField('Header 2', _header2),
                    const SizedBox(height: AppSizes.paddingS),
                    _textField('Footer 1', _footer1),
                    const SizedBox(height: AppSizes.paddingS),
                    _textField('Footer 2', _footer2),
                    const SizedBox(height: AppSizes.paddingM),
                    const Text(
                      'AMOUNT FILTER SETTINGS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    _textField('Enter Amount to set filter', _amountFilter,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: AppSizes.paddingL),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Printer settings saved (dummy)'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('SUBMIT'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _header1.clear();
                              _header2.clear();
                              _footer1.clear();
                              _footer2.clear();
                              _amountFilter.text = '500.0';
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('CLEAR'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            isDense: true,
          ),
        ),
      ],
    );
  }
}

