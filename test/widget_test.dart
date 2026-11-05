import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('auth app shows login screen on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RailwayApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue your journey'), findsOneWidget);
  });
}
