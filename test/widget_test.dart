import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mr_void/targets_screen.dart';

void main() {
  testWidgets('MR VOID displays the daily targets screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TargetsScreen(),
      ),
    );

    expect(find.text('MR VOID'), findsOneWidget);
    expect(find.text('Your daily targets'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Age (years)'), findsOneWidget);
    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(find.text('Height (cm)'), findsOneWidget);
  });
}
