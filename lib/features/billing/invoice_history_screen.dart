import 'package:flutter/material.dart';
import '../../core/data/customer.dart';

// Placeholder invoice model
class _Invoice {
  final String invoiceNumber;
  final String invoiceDate;
  final String dueDate;
  final String billNumber;
  final String billAmount;
  final String taxAmount;
  final String pendingAmount;
  final String packageName;
  final String totalAmount;

  const _Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.billNumber,
    required this.billAmount,
    required this.taxAmount,
    required this.pendingAmount,
    required this.packageName,
    required this.totalAmount,
  });
}

class InvoiceHistoryScreen extends StatelessWidget {
  final Customer customer;
  const InvoiceHistoryScreen({super.key, required this.customer});

  // Placeholder invoices
  List<_Invoice> get _invoices => [
        const _Invoice(
          invoiceNumber: '6476563',
          invoiceDate: '2023-07-01',
          dueDate: '2023-07-02',
          billNumber: '51F8B20230701116776',
          billAmount: '₹15266',
          taxAmount: '₹2765',
          pendingAmount: '₹6740',
          packageName: 'abcd - Addon ,Bill Generation34 - Addon ,laxmi cable - Addon',
          totalAmount: '₹24770',
        ),
        const _Invoice(
          invoiceNumber: '6391989',
          invoiceDate: '2023-06-01',
          dueDate: '2023-06-01',
          billNumber: '5DAB920230601116776',
          billAmount: '₹110355',
          taxAmount: '₹34653',
          pendingAmount: '₹75573',
          packageName: 'abcd - Addon ,Bill Generation34 - Addon',
          totalAmount: '₹110355',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF0D47A1),
            child: Text(
              'Total Invoices : ${_invoices.length}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: _invoices.length,
              itemBuilder: (_, i) => _InvoiceCard(invoice: _invoices[i]),
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
      title: const Text('INVOICE HISTORY',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final _Invoice invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D47A1).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Invoice number header row (grey background like photo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text('Invoice Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                const Spacer(),
                Text(invoice.invoiceNumber,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1B3A7A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row('Invoice Date', invoice.invoiceDate),
                _row('Due Date', invoice.dueDate),
                _row('Bill Number', invoice.billNumber),
                _row('Bill Amount', invoice.billAmount),
                _row('Tax Amount', invoice.taxAmount),
                _row('Pending Amount', invoice.pendingAmount),
                _row('Package Name', invoice.packageName),
                // Total amount row with print + share icons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('Total Amount',
                            style: TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
                      ),
                      Expanded(
                        child: Text(invoice.totalAmount,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
                      ),
                      const Icon(Icons.print, color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1565C0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(label,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}