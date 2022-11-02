// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:advent_calendar_app/CalendarDoorContent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advent_calendar_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AdventCalendarApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Number of snowflakes', (WidgetTester tester) async {
    const int maxDoorCount = 24;
    const ClippedSnowfall clippedSnowfall = ClippedSnowfall(isDoorFullyClosed: true, doorNumber: 0, maxDoorCount: 0);
    final snowflakeCounts = [for (var i = 1; i <= maxDoorCount; i++) clippedSnowfall.numberOfSnowflakes(i, maxDoorCount)];
    expect(snowflakeCounts, [0, 0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 8]);
  });
}
