import 'dart:io' show Platform;
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ScreenSecurityImpl {
  static Future<void> protect() async {
    // Only apply on Android as per flutter_windowmanager requirements
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // ignore errors on non-android
      }
    }
  }
  
  static Future<void> unprotect() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // ignore errors on non-android
      }
    }
  }
}
