import 'package:flutter/services.dart';
import 'dart:developer' as developer;

const platform = MethodChannel('com.screen_reader/projection');


Future<void> startProjection() async {
  try {
    await platform.invokeMethod('startProjection');
  } on PlatformException catch (e) {
    developer.log("Failed to start screen reader: '${e.message}'.", name: 'ScreenReader');
  }
}
