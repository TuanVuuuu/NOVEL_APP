import 'package:flutter/foundation.dart';

void apiLogger(String api, dynamic param) {
  if (kDebugMode) {
    print('API: $api');
    print(param);
  }
}

void apiLoggerStateSuccess(String api) {
  if (kDebugMode) {
    print('API: $api load Success');
  }
}

void apiLoggerStateFailure(String api) {
  if (kDebugMode) {
    print('API: $api load Failure');
  }
}
