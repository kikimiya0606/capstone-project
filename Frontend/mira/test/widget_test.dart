import 'package:flutter_test/flutter_test.dart';
import 'package:mira/main.dart';

void main() {
  testWidgets('온보딩에서 로그인으로 이동한다', (tester) async {
    await tester.pumpWidget(const MiraApp());
    expect(find.text('MIRA'), findsOneWidget);
    await tester.tap(find.text('건너뛰기'));
    await tester.pumpAndSettle();
    expect(find.text('로그인'), findsOneWidget);
  });
}
