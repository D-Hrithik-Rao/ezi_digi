import 'package:flutter/material.dart';
import '../../core/data/customer.dart';

class ComplaintHistoryScreen extends StatelessWidget {
  final Customer customer;
  const ComplaintHistoryScreen({super.key, required this.customer});

  // Placeholder data matching the photo style
  List<Map<String, String>> get _complaints => [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Total count bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF0D47A1),
            child: Text(
              'Total Count - ${_complaints.length}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),

          // Customer Info
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _cRow('Customer Name', customer.name),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                _cRow('Address', customer.address.isEmpty ? 'N/A' : customer.address),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                _cRow('Mobile No.', customer.primaryMobileNumber.isEmpty ? 'N/A' : customer.primaryMobileNumber, isLast: true),
              ],
            ),
          ),

          Expanded(
            child: _complaints.isEmpty
                ? const Center(
                    child: Text('No complaints found',
                        style: TextStyle(color: Colors.white70, fontSize: 15)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: _complaints.length,
                    itemBuilder: (_, i) => _ComplaintCard(data: _complaints[i]),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      title: const Text('COMPLAINT HISTORY',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
    );
  }

  Widget _cRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
          ),
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, String> data;
  const _ComplaintCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D47A1).withValues(alpha: 0.15)),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(entries[i].key,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
                    ),
                    Expanded(
                      child: Text(entries[i].value,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
                    ),
                  ],
                ),
              ),
              if (i < entries.length - 1)
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
            ],
          );
        }),
      ),
    );
  }
}