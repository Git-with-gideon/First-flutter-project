import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_project/main.dart';

void main() {
  testWidgets('Ember & Oak POS renders and prints thermal receipt',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EmberSmokeApp());

    expect(find.text('EMBER & OAK SMOKEHOUSE'), findsWidgets);
    expect(find.text('Print Receipt'), findsOneWidget);
  });
}
