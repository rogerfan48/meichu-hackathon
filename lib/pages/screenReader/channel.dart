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

Future<void> stopProjection() async {
  try {
    await platform.invokeMethod('stopProjection');
  } on PlatformException catch (e) {
    developer.log("Failed to stop screen reader: '${e.message}'.", name: 'ScreenReader');
  }
}

Future<bool> isAccessibilityServiceEnabled() async {
  try {
    return await platform.invokeMethod('isAccessibilityServiceEnabled') ?? false;
  } on PlatformException catch (e) {
    developer.log("Failed to check accessibility service: '${e.message}'.", name: 'ScreenReader');
    return false;
  }
}
