import 'package:flutter/foundation.dart';

/// 정원 성장(쿠키) 상태 + 오늘의 무드 상태를 앱 전역에서 공유하기 위한 싱글톤
class GardenState {
  GardenState._internal();
  static final GardenState instance = GardenState._internal();

  /// 쌓인 쿠키 개수 (garden_screen에서 ValueListenableBuilder로 구독)
  final ValueNotifier<int> cookieCount = ValueNotifier<int>(0);

  void addCookie() {
    cookieCount.value += 1;
  }

  // ── 오늘의 #mood 저장 상태 ──────────────────────────
  String moodText = '';
  String? selectedMood;

  void saveMood({required String moodText, String? selectedMood}) {
    this.moodText = moodText;
    this.selectedMood = selectedMood;
  }
}