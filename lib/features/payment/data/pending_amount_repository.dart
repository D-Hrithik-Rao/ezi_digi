import '../../../core/config/app_config.dart';
import '../../../core/network/server_url_resolver.dart';
import '../../../core/network/soap_client.dart';
import '../../../core/services/session_service.dart';

// Typed result so the caller knows success (statusCode) AND the value (amount).
class PendingAmountResult {
  final int statusCode; // 0 = ok
  final String statusMessage;
  final double pendingAmount; // the live amount the customer owes
  const PendingAmountResult(
      this.statusCode, this.statusMessage, this.pendingAmount);
}

/// Get Pending Amount (config key `gpa`).
/// Android: getPendingAmount, wrapper `pendingAmountInfo` (i:type getPendingAmountInfo).
class PendingAmountRepository {
  PendingAmountRepository._();
  static final PendingAmountRepository instance = PendingAmountRepository._();

  static String get _imei => AppConfig.deviceImei;

  /// [altCustomerId] = the customer's customer_id (NOT alt_cust_id — Android :1186/:1331).
  Future<PendingAmountResult> fetch(int altCustomerId) async {
    final ns = ServerUrlResolver.instance.namespace;
    final xml = await SoapClient.instance.call(
      url: ServerUrlResolver.instance.loginServerUrl,
      namespace: ns,
      soapAction: '$ns/getPendingAmount',
      methodName: 'getPendingAmount',
      wrapper: 'pendingAmountInfo',
      wrapperType: 'getPendingAmountInfo',
      fields: {
        'altCustomerId': altCustomerId,
        'authToken': SessionService.instance.authToken,
        'imei': _imei,
      },
    );
    final status =
        int.tryParse(SoapClient.readField(xml, 'statusCode') ?? '') ?? 3;
    final message = SoapClient.readField(xml, 'statusMessage') ?? '';
    final pending =
        double.tryParse(SoapClient.readField(xml, 'pendingAmount') ?? '') ?? 0.0;
    return PendingAmountResult(status, message, pending);
  }
}
