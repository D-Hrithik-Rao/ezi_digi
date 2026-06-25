import 'package:flutter/foundation.dart';
import '../../core/data/customer.dart';
import '../../core/services/error_handler_service.dart';
import 'data/dealer_groups_repository.dart';
import 'data/unpaid_customers_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerListProvider — ChangeNotifier for CustomerListScreen.
// Customer List (`uc`) is API-only: the server returns the FULL list (no
// pagination, no local cache) — mirrors Android's Unpaid_Fragment.
// ─────────────────────────────────────────────────────────────────────────────
class CustomerListProvider extends ChangeNotifier {
  // ── List state ───────────────────────────────────────────────────────────────
  List<Customer> _customers = [];
  bool _isLoading = false;
  bool _loaded = false;
  int _statusCode = 0; // 0 ok · 1 no records · 3 failed
  String _statusMessage = '';
  String _customerType = 'Total Unpaid List';
  String _group = 'Select';

  List<Customer> get customers     => _customers;
  bool           get isLoading     => _isLoading;
  bool           get loaded        => _loaded;
  int            get statusCode    => _statusCode;
  String         get statusMessage => _statusMessage;
  String         get customerType  => _customerType;
  String         get group         => _group;
  bool           get hasError      => _loaded && _statusCode == 3;

  // ── Dealer groups (config key `dg`) for the Group filter dropdown ──────────────
  List<DealerGroup> _groups = const [DealerGroup(0, 'Select')];
  List<DealerGroup> get groups     => _groups;
  List<String>      get groupNames => _groups.map((g) => g.name).toList();

  /// group_id for the currently selected group name (sent to `uc`).
  int get selectedGroupId => _groups
      .firstWhere((g) => g.name == _group,
          orElse: () => const DealerGroup(0, 'Select'))
      .id;

  /// Load dealer groups from the API to populate the dropdown.
  Future<void> loadGroups() async {
    try {
      _groups = await DealerGroupsRepository.instance.fetch();
      notifyListeners();
    } catch (_) {
      // keep the default ['Select'] on failure
    }
  }

  // ── Filters ────────────────────────────────────────────────────────────────
  void setCustomerType(String value) {
    if (_customerType == value) return;
    _customerType = value;
    refresh();
  }

  void setGroup(String value) {
    if (_group == value) return;
    _group = value;
    refresh();
  }

  // ── Load (uc) ────────────────────────────────────────────────────────────────
  Future<void> initialLoad() async {
    if (_loaded) return;
    await fetch();
  }

  Future<void> refresh() async {
    _loaded = false;
    await fetch();
  }

  Future<void> fetch() async {
    if (_isLoading || _loaded) return; // uc loads the full list once; no pagination
    _isLoading = true;
    notifyListeners();
    try {
      final result = await UnpaidCustomersRepository.instance.fetch(
        customerStatus: _customerStatus(),
        stbStatus: -1,
        unpaidListType: 1,
        groupId: selectedGroupId,
        billMonth: _billMonth(),
      );
      _statusCode = result.statusCode;
      _statusMessage = result.statusMessage;
      _customers = result.customers;
    } catch (error, stackTrace) {
      _statusCode = 3;
      _statusMessage = 'Server is busy or not reachable';
      _customers = [];
      ErrorHandlerService.recordError(error, stackTrace,
          reason: 'CustomerListProvider.fetch');
    } finally {
      _isLoading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  // 'Total Unpaid List' → -1 (all) · 'Active Customers' → 1 · 'Inactive Customers' → 2
  int _customerStatus() {
    switch (_customerType) {
      case 'Active Customers':
        return 1;
      case 'Inactive Customers':
        return 2;
      default:
        return -1;
    }
  }

  // billmonth format "M-yyyy" (Android: Unpaid_Fragment tv_dateset).
  String _billMonth() {
    final now = DateTime.now();
    return '${now.month}-${now.year}';
  }
}
