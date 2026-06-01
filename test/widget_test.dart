import 'package:flutter_test/flutter_test.dart';
import 'package:empower_wellness/main.dart';

void main() {
  testWidgets('App starts and renders splash', (tester) async {
    await tester.pumpWidget(const EmpowerWellnessApp());
    // Splash screen should show the app name
    await tester.pump();
    expect(find.text('EmpowerWellness'), findsOneWidget);
    expect(find.text('Your world is evolving'), findsOneWidget);
  });
}
