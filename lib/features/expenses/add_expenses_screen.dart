import 'package:flutter/material.dart';
import '../../core/data/expense.dart';
import '../../core/data/expense_storage.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  String selectedDate = DateTime.now().toString().split(' ')[0];
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController taxValController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String category = "PETROL";
  String paymentMode = "Cash";
  String taxType = "₹";

  double get amountVal => double.tryParse(amountController.text) ?? 0.0;
  double get taxVal => double.tryParse(taxValController.text) ?? 0.0;

  double get totalTaxRs {
    if (taxType == "₹") return taxVal;
    // If it's percentage %
    return amountVal * (taxVal / 100);
  }

  double get totalAmount => amountVal + totalTaxRs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Expenses",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Expenses & Category Type
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Expenses *",
                    controller: expenseController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: "Category Type *",
                    value: category,
                    items: const ["PETROL", "RENT", "FOOD", "OTHER"],
                    onChanged: (val) => setState(() => category = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2: Date & Payment Mode
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Date",
                    readOnly: true,
                    controller: TextEditingController(text: selectedDate),
                    suffixIcon: Icons.calendar_today_outlined,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked.toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: "Payment Mode",
                    value: paymentMode,
                    items: const ["Cash", "Online", "Card"],
                    onChanged: (val) => setState(() => paymentMode = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 3: Amount & Tax Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Amount *",
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildDropdown(
                        label: "Tax Type",
                        value: taxType,
                        items: const ["₹", "%"],
                        onChanged: (val) => setState(() => taxType = val!),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: "",
                        hint: "0",
                        controller: taxValController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 4: Invoice & Receipt
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Invoice Number",
                    controller: invoiceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: "Receipt",
                    hint: "No file choosen",
                    readOnly: true,
                    suffixIcon: Icons.attach_file_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 5: Remarks
            _buildTextField(
              label: "Remarks",
              controller: remarksController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Expenses Details Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3FB), // Light indigo tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Expenses Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailField("Amount", "₹${amountVal.toStringAsFixed(1)}"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDetailField("Total Tax(In Rs)", "₹${totalTaxRs.toStringAsFixed(1)}"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDetailField("Total", "₹${totalAmount.toStringAsFixed(1)}"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _addExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1), // Blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Add", style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC60000), // Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _clearFields,
                    child: const Text("Clear", style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _addExpense() {
    if (expenseController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill required fields")),
      );
      return;
    }
    ExpenseStorage.expenses.add(
      Expense(
        title: expenseController.text,
        category: category,
        date: selectedDate,
        amount: totalAmount,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense Added successfully")),
    );
    _clearFields();
  }

  void _clearFields() {
    expenseController.clear();
    amountController.clear();
    taxValController.clear();
    invoiceController.clear();
    remarksController.clear();
    setState(() => taxType = "₹");
  }

  // Helper Widget for TextFields
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hint,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black54, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1)),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Dropdowns
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1)),
            ),
          ),
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Helper Widget for Detail Box Fields
  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
