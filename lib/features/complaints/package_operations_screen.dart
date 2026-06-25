import 'package:flutter/material.dart';
import '../../../core/data/customer.dart';

class PackageOperationsScreen extends StatefulWidget {
  final Customer customer;
  const PackageOperationsScreen({super.key, required this.customer});

  @override
  State<PackageOperationsScreen> createState() => _PackageOperationsScreenState();
}

class _PackageOperationsScreenState extends State<PackageOperationsScreen> {
  String _selectedSerial = '';

  @override
  void initState() {
    super.initState();
    _selectedSerial = widget.customer.serialNumber.isEmpty
        ? widget.customer.boxNumber
        : widget.customer.serialNumber;
  }

  void _confirmReactivate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reactivate Box',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to Reactivate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Box Reactivated Successfully'), backgroundColor: Colors.green),
              );
            },
            child: const Text('YES', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Customer info card
            _WhiteCard(
              child: Column(
                children: [
                  _row('Customer Name', widget.customer.name),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                  _row('LCO Customer Id', widget.customer.lcoCustomerId),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                  // Serial Number dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 130,
                          child: Text('Serial Number',
                              style: TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSerial.isEmpty ? null : _selectedSerial,
                                isDense: true,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                items: [widget.customer.serialNumber, widget.customer.boxNumber]
                                    .where((e) => e.isNotEmpty)
                                    .toSet()
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedSerial = v ?? ''),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                  _row('VC Number', widget.customer.vcNumber, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Services card
            _WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services(${_selectedSerial.isEmpty ? widget.customer.serialNumber : _selectedSerial})',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1)),
                  ),
                  const SizedBox(height: 12),

                  _ServiceTile(
                    label: 'Active Packages',
                    onTap: () => _showActivePackages(),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  _ServiceTile(
                    label: 'Add Services',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ServicesScreen(
                          title: 'ADD SERVICES',
                          customer: widget.customer,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  _ServiceTile(
                    label: 'Schedule Services',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ServicesScreen(
                          title: 'SCHEDULE SERVICES',
                          customer: widget.customer,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  _ServiceTile(
                    label: 'Reactivation',
                    onTap: _confirmReactivate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivePackages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivePackagesScreen(customer: widget.customer),
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
      title: const Text('PACKAGE OPERATIONS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
    );
  }

  Widget _row(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
        if (!isLast) const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ServiceTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00ACC1))),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF00ACC1)),
          ],
        ),
      ),
    );
  }
}

class ActivePackagesScreen extends StatefulWidget {
  final Customer customer;
  const ActivePackagesScreen({super.key, required this.customer});

  @override
  State<ActivePackagesScreen> createState() => _ActivePackagesScreenState();
}

class _ActivePackagesScreenState extends State<ActivePackagesScreen> {
  String _status = 'Select';
  final _statuses = ['Select', 'Active', 'Deactive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
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
        title: const Text('ACTIVE PACKAGES',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0277BD), Color(0xFF26C6DA)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('ACTIVE PACKAGES',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Serial Number',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5B7BAE))),
                    Text(widget.customer.serialNumber.isEmpty ? widget.customer.boxNumber : widget.customer.serialNumber,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vc Number',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5B7BAE))),
                    Text(widget.customer.vcNumber,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Choose Status',
              style: TextStyle(fontSize: 13, color: Color(0xFF5B7BAE))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _status,
                isExpanded: true,
                items: _statuses
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Select'),
              ),
            ),
          ),
            const SizedBox(height: 20),
            // Placeholder base pack text as requested
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0D47A1).withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Base Pack', style: TextStyle(fontSize: 12, color: Color(0xFF5B7BAE))),
                  const SizedBox(height: 4),
                  const Text('GOLD Pack Postpaid', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status: Active', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
                      const Text('₹140 / mo', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Services Screen (Add Services / Schedule Services)
class _ServicesScreen extends StatefulWidget {
  final String title;
  final Customer customer;
  const _ServicesScreen({required this.title, required this.customer});

  @override
  State<_ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<_ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _search = TextEditingController();

  // Placeholder packages
  final _addOn = [
    {'name': 'ECF', 'price': '₹120'},
    {'name': 'GOLD Pack Postpaid', 'price': '₹140'},
    {'name': 'GOLD SUV', 'price': '₹25'},
    {'name': 'RTFC', 'price': '₹78'},
    {'name': 'Silver Pack', 'price': '₹56'},
    {'name': 'Silver SUV', 'price': '₹60'},
  ];
  final _alacarte = [
    {'name': 'Ala Sony HD', 'price': '₹250'},
    {'name': 'SONY HD', 'price': '₹200'},
  ];
  final _base = <Map<String, String>>[];

  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tab.dispose();
    _search.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _currentList {
    switch (_tab.index) {
      case 0:
        return _base;
      case 1:
        return _addOn;
      case 2:
        return _alacarte;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
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
        title: Text(widget.title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
      ),
      body: Column(
        children: [
          // Tab bar card
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tab,
              onTap: (_) => setState(() {}),
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.red, width: 2.5),
              ),
              tabs: const [
                Tab(text: 'Base'),
                Tab(text: 'Add On'),
                Tab(text: 'Alacarte'),
              ],
            ),
          ),

          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '',
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          // List
          Expanded(
            child: _currentList.isEmpty
                ? const Center(
                    child: Text('List is Empty',
                        style: TextStyle(fontSize: 18, color: Colors.black54)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _currentList
                        .where((e) => e['name']!
                            .toLowerCase()
                            .contains(_search.text.toLowerCase()))
                        .length,
                    itemBuilder: (_, i) {
                      final filtered = _currentList
                          .where((e) => e['name']!
                              .toLowerCase()
                              .contains(_search.text.toLowerCase()))
                          .toList();
                      final item = filtered[i];
                      final name = item['name']!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CheckboxListTile(
                          value: _selected.contains(name),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(name);
                              } else {
                                _selected.remove(name);
                              }
                            });
                          },
                          activeColor: const Color(0xFF0D47A1),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D47A1))),
                          subtitle: Text(item['price']!,
                              style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_selected.isEmpty
                    ? 'No packages selected'
                    : 'Saved: ${_selected.join(", ")}'),
                backgroundColor: const Color(0xFF0D47A1),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('SAVE',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D47A1))),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}