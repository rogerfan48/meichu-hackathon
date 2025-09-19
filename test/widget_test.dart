// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dyslexia_assist/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
  await tester.pumpWidget(const AppRoot());

    // Verify that our counter starts at 0.
  // Basic sanity: finds MaterialApp title widget tree exists
  expect(find.byType(MaterialApp), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
  // No counter in this app yet; just ensure no exceptions.
  });
}
