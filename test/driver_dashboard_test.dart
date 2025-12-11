import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waste_management_app/features/driver/screens/advanced_driver_dashboard.dart';

void main() {
  testWidgets('Driver Dashboard builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdvancedDriverDashboard(),
      ),
    );

    expect(find.text('Driver Dashboard'), findsOneWidget);
    expect(find.text('You are Offline'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('Online toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdvancedDriverDashboard(),
      ),
    );

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    
    await tester.tap(switchFinder);
    await tester.pump();
    
    expect(find.text('You are Online'), findsOneWidget);
  });
}
