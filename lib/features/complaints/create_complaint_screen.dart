import 'package:flutter/material.dart';
import '../../core/data/customer.dart';

class CreateComplaintScreen extends StatefulWidget {
  final Customer customer;
  const CreateComplaintScreen({super.key, required this.customer});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  String? _selectedCategory;
  String? _selectedAssignTo;
  String? _selectedEmployee;
  final _descController = TextEditingController();

  final _categories = [
    'Select', 'Box Missing', 'Remote Problem', 'cable problem',
    'VC Card chip problem', 'package addition request', 'Package addition',
    'Invoice issue', 'No Signal', 'Box Problem', 'sound issue',
  ];

  final _assignOptions = ['Employee', 'Service'];

  final _employees = [
    'Select', 'Eswar (EMPLOYEE)', 'Sagar (EMPLOYEE)', 'Devlakl Lak(EMPLOYEE)',
    'Mahesh (EMPLOYEE)', 'Nandini (EMPLOYEE)', 'Raju (EMPLOYEE)',
    'Naveen (EMPLOYEE)', 'Sharath (SERVICE)',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _register() {
    if (_selectedCategory == null || _selectedCategory == 'Select') {
      _snack('Please select a complaint category');
      return;
    }
    if (_selectedEmployee == null || _selectedEmployee == 'Select') {
      _snack('Please select an employee/service');
      return;
    }
    _snack('Complaint registered successfully!', success: true);
    Navigator.pop(context);
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Complaint Category
              const Text('Complaint Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
              const SizedBox(height: 10),
              _dropdown(
                value: _selectedCategory ?? 'Select',
                items: _categories,
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 20),

              // Assign To
              const Text('Assign To',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
              const SizedBox(height: 10),
              _dropdown(
                value: _selectedAssignTo ?? 'Employee',
                items: _assignOptions,
                onChanged: (v) => setState(() => _selectedAssignTo = v),
              ),
              const SizedBox(height: 20),

              // Select Employee/Service
              const Text('Select Employee/Service',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
              const SizedBox(height: 10),
              _dropdown(
                value: _selectedEmployee ?? 'Select',
                items: _employees,
                onChanged: (v) => setState(() => _selectedEmployee = v),
              ),
              const SizedBox(height: 20),

              // Description
              const Text('Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Register button
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Register',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
      title: const Text('NEW COMPLAINT',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
    );
  }
}