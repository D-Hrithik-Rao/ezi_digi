import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _customerType = 'Total Unpaid List';
  String _group = 'Select';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'CUSTOMER LIST',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                AppSizes.paddingM,
                0,
                AppSizes.paddingM,
                AppSizes.paddingS,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TabBar(
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.redAccent, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 28),
                ),
                labelColor: Colors.redAccent,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Unpaid List'),
                  Tab(text: 'Paid List'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildFilters(),
            const Center(
              child: Text(
                'Paid List (dummy)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          _CardRow(
            title: 'Advance Search',
            trailing: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Advance Search (coming soon)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text('View'),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _DropCard(
            title: 'Customer Type *',
            value: _customerType,
            items: const [
              'Total Unpaid List',
              'Active Customers',
              'Inactive Customers',
            ],
            onChanged: (v) => setState(() => _customerType = v),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _DropCard(
            title: 'Group',
            value: _group,
            items: const ['Select', 'Group A', 'Group B', 'Group C'],
            onChanged: (v) => setState(() => _group = v),
          ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _CardRow({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _DropCard extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropCard({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Iconsax.arrow_down_1),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

