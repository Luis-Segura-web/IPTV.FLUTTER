// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_flutter/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IPTVApp());

    // Verify that the splash screen is displayed
    expect(find.text('IPTV Flutter'), findsOneWidget);
    expect(find.text('Streaming Made Simple'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App has correct theme configuration', (WidgetTester tester) async {
    await tester.pumpWidget(const IPTVApp());

    final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
    
    expect(materialApp.title, 'IPTV Flutter');
    expect(materialApp.debugShowCheckedModeBanner, false);
    expect(materialApp.themeMode, ThemeMode.system);
  });
}
