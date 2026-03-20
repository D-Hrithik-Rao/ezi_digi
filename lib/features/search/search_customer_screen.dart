import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/database/database_helper.dart';
import '../../core/data/customer.dart';
import '../customer/customer_details_screen.dart';

class SearchCustomerScreen extends StatefulWidget {
  const SearchCustomerScreen({super.key});

  @override
  State<SearchCustomerScreen> createState() => _SearchCustomerScreenState();
}

class _SearchCustomerScreenState extends State<SearchCustomerScreen> {
  final _searchController = TextEditingController();
  String _criteria = 'Name';
  List<Customer> _searchResults = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _dbHelper.insertDemoData();
    } catch (e) {
      print('Database already initialized or error: $e');
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _dbHelper.searchCustomers(_criteria, query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Search error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEARCH CUSTOMER'),
      ),
      body: Container(
        color: AppColors.primary,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('SEARCH CUSTOMER'),
              const SizedBox(height: AppSizes.paddingS),
              _criteriaDropdown(),
              const SizedBox(height: AppSizes.paddingS),
              _searchBox(),
              const SizedBox(height: AppSizes.paddingL),
              if (_searchResults.isNotEmpty || _isLoading)
                _buildSectionHeader('SEARCH RESULT BY $_criteria', trailing: 'Total Count - ${_searchResults.length}'),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              if (!_isLoading && _searchResults.isEmpty && _searchController.text.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              if (!_isLoading)
                ..._searchResults.map((customer) => _customerResultCard(customer)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text, {String? trailing}) {
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
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _criteriaDropdown() {
    const items = [
      'Alt Customer Id',
      'Name',
      'Primary Mobile Number',
      'Lco  Customer Id',
      'CRF Number',
      'Serial Number',
      'VC Number',
      'NickName',
      'Secondary Mobile Number',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _criteria,
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
            setState(() {
              _criteria = v;
              _searchResults.clear();
            });
            if (_searchController.text.isNotEmpty) {
              _performSearch(_searchController.text);
            }
          },
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter search text',
              ),
            ),
          ),
          Container(
            height: 44,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Icon(Iconsax.search_normal, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _customerResultCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Customer Name', customer.name),
          _detailRow('Pending Amount', customer.pendingAmount),
          _detailRow('Last Paid Date', customer.lastPaidDate),
          _detailRow('Customer Type', customer.customerType),
          _detailRow('Address', customer.address),
          const SizedBox(height: AppSizes.paddingS),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerDetailsScreen(customer: customer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              child: const Text('View'),
            ),
          ),
        ],
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
}

