import 'dart:ui';

import 'package:flutter/foundation.dart';

class ErrorHandlerService {
  ErrorHandlerService._();

  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: 'Flutter framework error',
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      recordError(error, stack, reason: 'Platform dispatcher error');
      return true;
    };
  }

  static void recordError(Object error, StackTrace stack, {String? reason}) {
    final prefix = reason != null ? '[$reason]' : '[Unhandled error]';
    debugPrint('$prefix ${error.toString()}');
    debugPrint(stack.toString());
  }
}
