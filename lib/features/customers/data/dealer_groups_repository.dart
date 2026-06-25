import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/network/rest_client.dart';
import '../../../core/network/server_url_resolver.dart';
import '../../../core/services/session_service.dart';

/// One dealer group for the Group filter dropdown.
class DealerGroup {
  final int id;
  final String name;
  const DealerGroup(this.id, this.name);
}

/// Dealer Groups (config key `dg`).
///
/// Android: `Unpaid_Fragment` Volley form-POST to `NAMESPACE/packagelist/dealerGroups`
/// with params `dealer_id`, `imei`, `authtoken`. Response JSON:
///   { status_code, status_msg, group_details: "[{group_id, group_name}, ...]" }
/// `group_details` is a JSON STRING. A leading "Select" (id 0) entry is prepended
/// (Android: `statename.add("Select"); stateid.add(0)`).
class DealerGroupsRepository {
  DealerGroupsRepository._();
  static final DealerGroupsRepository instance = DealerGroupsRepository._();

  static String get _imei => AppConfig.deviceImei;

  static const DealerGroup _select = DealerGroup(0, 'Select');

  Future<List<DealerGroup>> fetch() async {
    final url =
        '${ServerUrlResolver.instance.namespace}/packagelist/dealerGroups';

    final data = await RestClient.instance.postForm(url, {
      'dealer_id': SessionService.instance.dealerId,
      'imei': _imei,
      'authtoken': SessionService.instance.authToken,
    });

    final status = data['status_code'];
    if (status != 0 && status != '0') {
      return const [_select];
    }

    // group_details is a JSON string holding the array (Android double-encodes it).
    final raw = data['group_details'];
    final list = raw is String ? jsonDecode(raw) : raw;

    final groups = <DealerGroup>[_select];
    if (list is List) {
      for (final item in list) {
        if (item is Map) {
          groups.add(DealerGroup(
            int.tryParse('${item['group_id']}') ?? 0,
            '${item['group_name'] ?? ''}',
          ));
        }
      }
    }
    return groups;
  }
}
