import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_hello_world/main.dart';

void main() {
  testWidgets('Hello World screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // Build the app and trigger a frame.

    expect(find.text('Hello World!'), findsOneWidget); // Verify that the text "Hello World!" is displayed on the screen.
    expect(find.text('Hello World'), findsOneWidget); // Verify that the text "Hello World" (without the exclamation mark) is also displayed on the screen.
  }); 
}
