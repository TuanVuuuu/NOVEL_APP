// import 'dart:convert';
import 'dart:isolate';
import 'package:audiobook/utils/text_content.dart';
import 'package:flutter/foundation.dart';

void apiLogger(String api, dynamic param) {
  if (kDebugMode) {
    printHd();
    print('║ API: $api');
    printBd();
    print('║ $param');
    printBd();
    print('║ Time: ${DateTime.now()}');
    printFooter();
  }
}

void apiGetLogger(String api, dynamic param) {
  if (kDebugMode) {
    printHd();
    print('║ API: $api');
    printBd();
    print('║ Request ║ GET $param');
    printBd();
    print('║ Time: ${DateTime.now()}');
    printFooter();
  }
}

void apiLoggerStateSuccess(String api, dynamic param) {
  if (kDebugMode) {
    printHd();
    print('║ API: $api ║ STATE: SUCCESS');
    printBd();
    print('║ Time: ${DateTime.now()}');
    printBd();
    print('║ Request ║ GET $param');
    printFooter();
  }
}

void apiLoggerStateFailure(String api) {
  if (kDebugMode) {
    printHd();
    print('║ API: $api ║ STATE: FAILURE');
    printBd();
    print('║ Time: ${DateTime.now()}');
    printFooter();
  }
}

void localGetLogger(String action, dynamic param) {
  if (kDebugMode) {
    printHd();
    print('║ ACTION: $action');
    printBd();
    print('║ $param');
    printBd();
    print('║ Time: ${DateTime.now()}');
    printFooter();
  }
}

void localLoggerStateSuccess(String action, dynamic response) {
  // final result =
  //     const JsonEncoder.withIndent('  ').convert(json.decode(response));
  if (kDebugMode) {
    // runPrintWrappedInIsolate('Response ║ $result', action);
  }
}

void printHd() {
  if (kDebugMode) {
    print(
        '╔══════════════════════════════════════════════════════════════════════════════════════════════════════');
  }
}

void printBd() {
  if (kDebugMode) {
    print(
        '╟──────────────────────────────────────────────────────────────────────────────────────────────────────');
  }
}

void printFooter() {
  if (kDebugMode) {
    print(footerLogString);
  }
}

Future<void> runPrintWrappedInIsolate(String text, String action) async {
  String input = text;
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(
    isolateFunction,
    {
      'text': input,
      'sendPort': receivePort.sendPort,
    },
  );

  printHd();
  if (kDebugMode) {
    print('║ ACTION: $action ║ STATE: SUCCESS');
  }

  await for (var message in receivePort) {
    if (message == 'done') {
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
      break;
    } else {
      if (kDebugMode) {
        print(message);
      }
    }
  }
}

void isolateFunction(Map<String, dynamic> params) {
  String text = params['text'];
  SendPort sendPort = params['sendPort'];

  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) {
    sendPort.send('║  ${match.group(0)}');
  });

  sendPort.send(footerLogString);

  sendPort.send('done');
  printBd();
  if (kDebugMode) {
    print('║ Time: ${DateTime.now()}');
  }
  printBd();
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) {
    if (kDebugMode) {
      print('║  ${match.group(0)}');
    }
  });
}
