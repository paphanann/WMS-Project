import 'package:flutter_test/flutter_test.dart';

import 'package:myproject/main.dart';

void main() {
  testWidgets('Login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PassWmsApp());
    await tester.pumpAndSettle();

    expect(find.text('เชื่อมต่อระบบ'), findsOneWidget);
    expect(find.text('ถัดไป'), findsOneWidget);
  });
}
