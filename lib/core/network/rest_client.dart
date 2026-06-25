import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when a REST call does not return HTTP 200 or returns a non-JSON body.
class RestException implements Exception {
  final String message;
  final int? statusCode;
  RestException(this.message, {this.statusCode});

  @override
  String toString() => 'RestException(${statusCode ?? '-'}): $message';
}

/// Minimal REST transport — the Flutter equivalent of the Android app's Volley
/// form POST. Sends `application/x-www-form-urlencoded` params and decodes the
/// JSON response. Used for the `/packagelist/...` and `/digi_rest_api/...` calls.
class RestClient {
  RestClient._();
  static final RestClient instance = RestClient._();

  /// Same User-Agent as the SOAP client — some Digi servers gate on it (403).
  static const String _userAgent = 'ksoap2-android/2.6.0+';

  /// POST [params] as form-encoded; return the decoded JSON object.
  Future<Map<String, dynamic>> postForm(
    String url,
    Map<String, String> params, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final res = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': _userAgent,
          },
          body: params,
        )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw RestException('HTTP ${res.statusCode}', statusCode: res.statusCode);
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw RestException('Unexpected response shape (not a JSON object)');
    }
    return decoded;
  }
}
