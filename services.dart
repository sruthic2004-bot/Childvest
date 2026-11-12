import 'package:flutter/services.dart';

class ScreenTimeService {
  static const platform = MethodChannel('screen_time');

  static Future<Map<String, int>> getScreenTime() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getScreenTime');
      return result.map((key, value) => MapEntry(key.toString(), value as int));
    } on PlatformException catch (e) {
      print("Failed to get screen time: '${e.message}'.");
      return {};
    }
  }
}
