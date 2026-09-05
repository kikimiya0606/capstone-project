# 강아지 방 통합

## 구조와 연결 위치

- 팀 저장소는 Backend와 Frontend로 구성되며 Flutter 앱 루트는 `Frontend/familyapp`이다.
- 앱은 `main.dart` → `SplashScreen`으로 시작하며 홈에서 질문, 가족 정원, 일정, 마이페이지로 이동한다.
- 기존 `garden_screen.dart`는 정원 이미지와 레벨업을 표시하고 `GardenState`의 쿠키를 사용한다.
- 원본 `dog_room/lib`는 모델, 컨트롤러, 저장 서비스, 방 화면, 상태 패널, 돌봄 버튼으로 분리되어 있다.
- 가족 정원 상단의 **강아지 방** 버튼으로 별도 route를 열고 뒤로가기로 정원으로 돌아온다. 정원 성장과 강아지 경험치는 독립적이다.

## 가져온 코드와 이미지

`lib/features/dog_room/` 아래에 원본 모델, 컨트롤러, 화면, 위젯을 재사용했다.
3초 이동과 2~5초 휴식, 무작위 목적지, 가구 영역을 피하는 목적지 선택, 좌우 반전, 호흡과 터치 효과, 돌봄 연출을 유지한다.
아기는 4장의 걷기 프레임을 사용한다. child/teen/adult는 원본처럼 단계별 정지 이미지에 이동과 상하 움직임을 적용한다.

성장 기준은 원본과 동일하다.

| 단계 | 경험치 | 시작 레벨 |
| --- | --- | --- |
| baby | 0~1000 | 1 |
| child | 1001~4000 | 6 |
| teen | 4001~9000 | 16 |
| adult | 9001 이상 | 31 |

밥 주기/목욕 +12 XP, 놀기 +18 XP, 재우기 +8 XP이며, 디버그 빌드에서는 원본의 +100 XP 테스트 버튼을 사용할 수 있다.
성체 보상 알림은 원본 UI이며 실제 상점 쿠폰 발급이나 팀 프로젝트 보상 시스템과 연결되지 않는다.

필요한 이미지 13개만 `assets/dog_room/`에 복사했다(강아지 9, 가구 3, 방 1). 사용하지 않는 꼬리 프레임, 원본 main, 플랫폼 설정, 빌드 결과는 복사하지 않았다.

## 통합 시 조정

- 저장 인터페이스를 유지하고 `SessionDogSaveService`로 대체했다. 방을 닫았다 열어도 상태가 유지되지만 **앱 프로세스를 재시작하면 초기화된다**. Firebase나 새 패키지 의존성은 추가하지 않았다.
- 앱바/뒤로가기, 작은 화면에서 스크롤 가능한 최소 높이를 추가했다.
- 원본에 존재하지 않는 `dog_idle.png` 오류 대체 경로를 기본 아이콘으로 수정했다.
- 원본의 타이머/애니메이션 컨트롤러 해제를 유지한다. 방 화면이 전달받은 DogController를 소유하고 닫힐 때 해제한다.
- 앱 `.gitignore`에 Flutter lib 예외를 추가했다. 저장소 루트의 Python `lib/` 규칙으로 새 Dart 파일이 누락되는 문제를 방지한다.

## 변경 파일

수정: `.gitignore`, `pubspec.yaml`(assets만 추가), `lib/garden_screen.dart`(import와 진입 버튼만 추가).

추가:

- `lib/features/dog_room/models/dog_state.dart`
- `lib/features/dog_room/controllers/dog_controller.dart`
- `lib/features/dog_room/services/dog_save_service.dart`
- `lib/features/dog_room/screens/dog_room_screen.dart`
- `lib/features/dog_room/widgets/dog_status_panel.dart`
- `lib/features/dog_room/widgets/care_action_bar.dart`
- `assets/dog_room/dog/*.png`, `assets/dog_room/furniture/*.png`, `assets/dog_room/room/room_background.png`
- `test/dog_room_test.dart`
- `DOG_ROOM_INTEGRATION.md`

## 검증

- `flutter test --no-pub test/dog_room_test.dart`: 7개 통과. 성장, 레벨, 시간 경과 상태 감소, 돌봄, 재입장 복원, 정원 복귀/쿠키 보존, 320×568 화면을 검증한다.
- 강아지 코드와 테스트 대상 정적 분석: 문제 없음.
- `flutter build web --no-pub`: 성공. 실제 기기에서의 수동 시각 검증은 수행하지 않았다.
- 전체 `flutter analyze --no-pub`: 기존 오류 2개, 경고 1개, info 14개. 기존 `test/widget_test.dart`의 `package:familyapp1/main.dart` import와 그에 따른 MyApp 참조 오류는 그대로 두었다. 기존 화면의 lint도 수정하지 않았다.
- Firebase 설정, 앱 시작점, 의존성, 기존 정원/쿠키 로직은 변경하지 않았다. commit/push는 실행하지 않았다.
