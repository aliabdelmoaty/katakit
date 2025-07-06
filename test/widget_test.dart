import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:katakit/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('🐣 كتاكيت عبد المعطي'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
