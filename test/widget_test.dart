import 'package:flutter_test/flutter_test.dart';
import 'package:havelin_food_apk/main.dart';
void main() {
  testWidgets('App renders Get started button', (WidgetTester tester) async {
    await tester.pumpWidget(const HavelinApp());
    expect(find.text('Get started'), findsOneWidget);
  });
}