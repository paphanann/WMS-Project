import 'package:flutter_test/flutter_test.dart';

import 'package:myproject/main.dart';

void main() {
  testWidgets('Login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PassWmsApp());
    await tester.pumpAndSettle();

    expect(find.text('ยินดีต้อนรับ'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
  });
}
