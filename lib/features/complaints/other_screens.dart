import 'package:flutter/material.dart';
import '../../core/data/customer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ACT-DEACT REPORT
// ─────────────────────────────────────────────────────────────────────────────
class ActDeactReportScreen extends StatelessWidget {
  final Customer customer;
  const ActDeactReportScreen({super.key, required this.customer});

  // Placeholder data
  final _records = const <Map<String, String>>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _appBar(context, 'ACT-DEACT REPORT'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _cRow('Customer Name', customer.name),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _cRow('LCO Customer Id', customer.lcoCustomerId),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _cRow('Serial Number', customer.serialNumber.isEmpty ? customer.boxNumber : customer.serialNumber, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _records.isEmpty
                ? const Center(child: Text('No act/deact records found', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _records.length,
                    itemBuilder: (_, i) => _SimpleCard(data: _records[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONE TIME CHARGES
// ─────────────────────────────────────────────────────────────────────────────
class OneTimeChargesScreen extends StatefulWidget {
  final Customer customer;
  const OneTimeChargesScreen({super.key, required this.customer});

  @override
  State<OneTimeChargesScreen> createState() => _OneTimeChargesScreenState();
}

class _OneTimeChargesScreenState extends State<OneTimeChargesScreen> {
  String _chargeType = 'Remote';
  bool _paid = false;
  DateTime _createdDate = DateTime.now();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  final _chargeTypes = ['Remote', 'Installation Charges', 'Visit Charges', 'Others'];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _createdDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _createdDate = picked);
  }

  void _save() {
    if (_amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment saved successfully'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  String get _fmtDate =>
      '${_createdDate.year}-${_createdDate.month.toString().padLeft(2, '0')}-${_createdDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _appBar(context, 'ONE TIME CHARGES'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // Customer Name
              _FormRow(label: 'Customer Name', child: Text(widget.customer.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1)))),
              const SizedBox(height: 14),

              // Charge Type
              _FormRow(
                label: 'Charge Type',
                child: DropdownButtonFormField<String>(
                  value: _chargeType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _chargeTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _chargeType = v ?? _chargeType),
                ),
              ),
              const SizedBox(height: 14),

              // Paid checkbox
              _FormRow(
                label: 'Paid',
                child: Checkbox(
                  value: _paid,
                  onChanged: (v) => setState(() => _paid = v ?? false),
                  activeColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 14),

              // Created date
              _FormRow(
                label: 'Created date',
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_fmtDate,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
                        ),
                        const Icon(Icons.calendar_month, color: Colors.red, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Amount
              _FormRow(
                label: 'Amount *',
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Remarks
              _FormRow(
                label: 'Remarks',
                child: TextField(
                  controller: _remarksCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Payment button
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('SAVE PAYMENT',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D47A1))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONE TIME HISTORY
// ─────────────────────────────────────────────────────────────────────────────
class OneTimeHistoryScreen extends StatelessWidget {
  final Customer customer;
  const OneTimeHistoryScreen({super.key, required this.customer});

  // Placeholder data matching photo
  List<Map<String, dynamic>> get _records => [
        {
          'receiptNo': 'CR485/1635317561/462',
          'billNo': '20211027122241',
          'chargeType': 'REMOTE',
          'amount': '100.00',
          'createdDate': '2021-10-27 12:22:41',
          'bank': 'NA',
          'branch': 'NA',
          'chequeNo': '0',
          'chequeDate': 'NA',
          'remarks': 'NA',
          'paid': true,
        },
        {
          'receiptNo': 'NA',
          'billNo': 'ITP452026031695212',
          'chargeType': 'INSTALLATION CHARGES',
          'amount': '200.00',
          'createdDate': '2026-03-16 09:51:12',
          'bank': 'NA',
          'branch': 'NA',
          'chequeNo': '0',
          'chequeDate': 'NA',
          'remarks': 'NA',
          'paid': false,
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _appBar(context, 'ONE TIME CHARGES HISTORY'),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF0D47A1),
            child: Text(
              'Total Count - ${_records.length}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          // Customer info
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _cRow('Customer Name', customer.name),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _cRow('Address', customer.address.isEmpty ? 'N/A' : customer.address),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _cRow('Mobile No.', customer.primaryMobileNumber.isEmpty ? 'N/A' : customer.primaryMobileNumber, isLast: true),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: _records.length,
              itemBuilder: (_, i) => _OneTimeCard(record: _records[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OneTimeCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _OneTimeCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D47A1).withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _r('Receipt No.', record['receiptNo']),
          _r('Bill No.', record['billNo']),
          _r('Charge Type', record['chargeType']),
          _r('Amount', record['amount']),
          _r('Created Date', record['createdDate']),
          _r('Bank', record['bank']),
          _r('Branch', record['branch']),
          _r('Cheque/DD No', record['chequeNo']),
          _r('Cheque Date', record['chequeDate']),
          _r('Remarks', record['remarks']),
          // Paid/Unpaid
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text('Paid/Unpaid',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
                ),
                Icon(
                  record['paid'] == true ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Operations row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text('Operations',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, color: Color(0xFF0D47A1), size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.print, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _r(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
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
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAY LATER
// ─────────────────────────────────────────────────────────────────────────────
class PayLaterScreen extends StatefulWidget {
  final Customer customer;
  const PayLaterScreen({super.key, required this.customer});

  @override
  State<PayLaterScreen> createState() => _PayLaterScreenState();
}

class _PayLaterScreenState extends State<PayLaterScreen> {
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String get _fmtDate =>
      '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';

  void _save() {
    if (_amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pay Later saved successfully'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _appBar(context, 'PAY LATER'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _FormRow(
                label: 'Customer Name',
                child: Text(widget.customer.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
              ),
              const SizedBox(height: 14),
              _FormRow(
                label: 'Total Due',
                child: Text(widget.customer.totalDue,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Colors.red)),
              ),
              const SizedBox(height: 14),
              _FormRow(
                label: 'Amount *',
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _FormRow(
                label: 'Due Date',
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_fmtDate,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
                        ),
                        const Icon(Icons.calendar_month, color: Colors.red, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _FormRow(
                label: 'Remarks',
                child: TextField(
                  controller: _remarksCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('SAVE',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

PreferredSizeWidget _appBar(BuildContext context, String title) {
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
    title: Text(title,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
  );
}

Widget _cRow(String label, String value, {bool isLast = false}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
            ),
          ],
        ),
      ),
      if (!isLast) const Divider(height: 1, color: Color(0xFFE5E7EB)),
    ],
  );
}

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5B7BAE), fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}

class _SimpleCard extends StatelessWidget {
  final Map<String, String> data;
  const _SimpleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
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
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ],
          );
        }),
      ),
    );
  }
}