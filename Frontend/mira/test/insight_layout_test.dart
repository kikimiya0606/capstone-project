import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira/main.dart';

void main() {
  testWidgets('Signal values align on narrow screens with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Insight('이야기 나눔', '2명', '이번 주 이야기를 남긴 가족'),
                  SizedBox(height: 28),
                  Insight('가족의 반응', '128개', '이번 주 글과 사진에 남은 좋아요'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopRight(find.text('2명')).dx,
      tester.getTopRight(find.text('128개')).dx,
    );
    expect(
      tester.getTopLeft(find.text('이야기')).dx,
      tester.getTopLeft(find.text('가족의').first).dx,
    );
  });
}
