import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class Logger {
  static void logMessage(
    String message, {
    String name = "MESSAGE",
    bool isCritical = false,
  }) {
    if (kDebugMode) {
      log(message, name: name);
    } else {
      if (isCritical) {
        // print("[$name] $message");
        FirebaseCrashlytics.instance.log(message);
      }
    }
  }

  static void logSoftError(String error, StackTrace? stackTrace) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } catch (_) {}
  }

  static void logError(
    String message, {
    String name = "ERROR",
    bool isCritical = false,
  }) {
    logMessage(message, name: name, isCritical: isCritical);
  }
}

class IsolateLogger {
  static void logMessage(String message, {String name = "ISOLATE"}) {
    if (kDebugMode) {
      log(message, name: name);
    } else {
      // print("[$name] $message");
      FirebaseCrashlytics.instance.log(message);
    }
  }

  static void logSoftError(String error, StackTrace? stackTrace) {
    try {
      // print("SOFT ERROR: $error, $stackTrace");
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } catch (_) {}
  }
}
