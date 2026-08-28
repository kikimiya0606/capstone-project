import 'package:flutter/material.dart';

/// 가족 구성원 역할과 역할별 색상을 앱 전역에서 관리하는 간단한 세션 클래스.
/// 로그인/역할 선택 시스템이 따로 없다면 이 static 클래스로 충분합니다.
/// 나중에 Firebase 등으로 옮기더라도 FamilyRole.colorOf(role) 부분만 바꾸면 됩니다.
class FamilyRole {
  // 역할별 고정 색상 (캘린더 상단 점 색과 동일하게 맞춤)
  static const Map<String, Color> roleColors = {
    '아빠': Color(0xFF6B9BE0), // 파랑
    '엄마': Color(0xFFE06B84), // 핑크
    '아들': Color(0xFF6BBF8E), // 초록
    '딸': Color(0xFFE0A15C), // 주황
  };

  // 역할별로 정원에서 키우는 캐릭터 종류 (에셋 파일명 접두어로 사용)
  // 예: 'tree_10.png', 'flower_60.png', 'cat_80.png', 'dog_100.png'
  static const Map<String, String> roleCreature = {
    '아빠': 'tree',
    '엄마': 'flower',
    '딸': 'cat',
    '아들': 'dog',
  };

  static Color colorOf(String? role) {
    if (role == null) return const Color(0xFFBBBBBB);
    return roleColors[role] ?? const Color(0xFFBBBBBB);
  }

  static String creatureOf(String? role) {
    if (role == null) return 'tree';
    return roleCreature[role] ?? 'tree';
  }
}

/// 현재 로그인(선택)된 가족 구성원 정보를 앱 전역에서 들고 다니는 세션.
class UserSession {
  static String? currentRole;

  static Color get currentColor => FamilyRole.colorOf(currentRole);

  static void setRole(String role) {
    currentRole = role;
  }
}