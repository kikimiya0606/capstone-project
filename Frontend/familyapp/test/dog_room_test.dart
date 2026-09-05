import 'package:familyapp/features/dog_room/controllers/dog_controller.dart';
import 'package:familyapp/features/dog_room/models/dog_state.dart';
import 'package:familyapp/features/dog_room/screens/dog_room_screen.dart';
import 'package:familyapp/features/dog_room/services/dog_save_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:familyapp/garden_screen.dart';
import 'package:familyapp/garden_state.dart';

class MemoryDogSaveService implements DogSaveService {
  DogState? stored;

  @override
  Future<DogState?> load() async => stored;

  @override
  Future<void> save(DogState state) async => stored = state;
}

void main() {
  test('방 재입장 시 세션의 성장 상태를 복원한다', () async {
    final service = SessionDogSaveService();
    final first = DogController(service);
    await first.initialize();
    await first.care(CareAction.feed);
    first.dispose();
    final second = DogController(service);
    await second.initialize();
    expect(second.state.experience, 12);
    expect(second.state.hunger, 94);
    second.dispose();
  });

  testWidgets('정원에서 입장하고 돌아와도 쿠키가 보존된다', (tester) async {
    GardenState.instance.cookieCount.value = 3;
    await tester.pumpWidget(const MaterialApp(home: GardenScreen()));
    await tester.tap(find.text('강아지 방'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DogRoomScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GardenScreen), findsOneWidget);
    expect(GardenState.instance.cookieCount.value, 3);
    await tester.pumpWidget(const SizedBox());
    GardenState.instance.cookieCount.value = 0;
  });

  testWidgets('작은 화면에서도 이동 영역과 돌봄 버튼을 사용할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = DogController(MemoryDogSaveService());
    await tester.pumpWidget(
      MaterialApp(home: DogRoomScreen(controller: controller)),
    );
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(seconds: 1));
      final position = tester.widget<AnimatedPositioned>(
        find.byKey(const ValueKey('dog-position')),
      );
      expect(position.left, inInclusiveRange(0, 180));
      expect(position.top, greaterThanOrEqualTo(0));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(find.text('밥 주기'));
    await tester.tap(find.text('밥 주기'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(controller.state.experience, 12);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  test('경험치에 따라 성장 단계가 결정된다', () {
    final now = DateTime(2026);
    expect(DogState(lastUpdated: now, experience: 0).stage, GrowthStage.baby);
    expect(
      DogState(lastUpdated: now, experience: 1000).stage,
      GrowthStage.baby,
    );
    expect(
      DogState(lastUpdated: now, experience: 1001).stage,
      GrowthStage.child,
    );
    expect(
      DogState(lastUpdated: now, experience: 4001).stage,
      GrowthStage.teen,
    );
    expect(
      DogState(lastUpdated: now, experience: 9001).stage,
      GrowthStage.adult,
    );
    expect(GrowthStage.baby.assetPath, 'assets/dog_room/dog/baby_idle.png');
    expect(GrowthStage.adult.assetPath, 'assets/dog_room/dog/adult_idle.png');
  });

  test('레벨과 성체 이후 보상이 무한히 이어진다', () {
    final now = DateTime(2026);
    expect(DogState(lastUpdated: now, experience: 0).level, 1);
    expect(DogState(lastUpdated: now, experience: 1000).level, 5);
    expect(DogState(lastUpdated: now, experience: 1001).level, 6);
    expect(DogState(lastUpdated: now, experience: 4001).level, 16);
    expect(DogState(lastUpdated: now, experience: 9001).level, 31);
    expect(DogState(lastUpdated: now, experience: 9501).level, 32);
    expect(
      DogState(lastUpdated: now, experience: 9501).nextAdultReward,
      AdultReward.motion,
    );
  });

  test('접속하지 않은 동안 상태가 감소하되 0보다 작아지지 않는다', () {
    final before = DateTime(2026, 1, 1, 12);
    final result = DogController.applyOfflineDecay(
      DogState(lastUpdated: before, hunger: 5, cleanliness: 5),
      before.add(const Duration(hours: 1)),
    );
    expect(result.hunger, 0);
    expect(result.cleanliness, 0);
  });

  testWidgets('밥 주기를 누르면 배부름과 경험치가 증가한다', (tester) async {
    final service = MemoryDogSaveService();
    final controller = DogController(service);
    await tester.pumpWidget(
      MaterialApp(home: DogRoomScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('밥 주기'), findsOneWidget);
    await tester.ensureVisible(find.text('밥 주기'));
    await tester.tap(find.text('밥 주기'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(controller.state.hunger, 94);
    expect(controller.state.experience, 12);
    expect(service.stored?.experience, 12);
    await tester.pumpWidget(const SizedBox());
  });
}
