# 백엔드 진행 상황 (2026-09-06 기준)

## 완료

### AI 서버 (`Backend/ai-server/`)
- Colab 프로토타입(감정 분석 + 공감 메시지 생성)을 실제 FastAPI 서비스로 이전
- `POST /analyze-mood`, `GET /health` 엔드포인트
- 원본 대비 버그 수정: 가족 구성원 수만큼 감정 분석·메시지 생성을 반복 호출하던 것 → 감정 분석 1회 + 메시지 생성 2회(본인용/가족용)로 정리, `family_message`는 전원 공유
- LLM은 Claude → **Gemini**(`gemini-3.6-flash`)로 교체 — 계정/결제 문제로 무료 티어 사용
- 실제 키로 `/analyze-mood` 호출 테스트 완료(정상 응답 확인), `pytest` 4개 통과
- 상세: `Backend/ai-server/README.md`

### Firestore + Cloud Functions 설계 (`Backend/`)
- `firestore-schema.md` — `users`, `families`(문서 id = 초대코드), `events`, `moods`, `dailyQuestions/answers`, `garden`, `holidays` 스키마
- `firestore.rules` — 가족 멤버십 기반 접근 제어 1차 초안
- `functions/` — Node.js Cloud Functions, `createFamily(role)` / `joinFamily(inviteCode, role)` 구현
- ⚠️ 스키마는 `Frontend/familyapp` 화면 코드를 분석해서 설계한 것 — `Frontend/mira`에 실제 화면이 들어오면 데이터 구조가 다를 수 있어 재검토 필요
- ⚠️ Firestore rules/Cloud Functions 둘 다 **에뮬레이터 검증 및 실제 배포 안 됨**

### Firebase 프로젝트 연결
- `firebase.json`/`.firebaserc`를 리포 루트로 이동 (hosting은 `Frontend/familyapp/build/web`, functions/firestore는 `Backend/` 참조)
- 프로젝트 ID `mood-12672`로 확정
- `familyapp`, `mira` 양쪽 `pubspec.yaml`에 Firebase 패키지 추가 (`firebase_core`, `cloud_firestore`, `firebase_auth`, `cloud_functions`, `firebase_messaging`)
- mira iOS 앱을 Firebase 콘솔에 등록(`com.a1hajo.mira`), `GoogleService-Info.plist` 파일을 `Frontend/mira/ios/Runner/`에 배치 + Xcode 프로젝트 리소스 등록까지 완료
- `Frontend/mira/lib/firebase_options.dart` 작성 (iOS만 채워져 있음, Android/Web은 등록 후 추가 필요)

### mira 회원가입/로그인/가족 설정 연동
- `Frontend/mira/lib/`에 화면·서비스 코드 신규 작성: `main.dart`(Firebase 초기화 + 로그인 상태에 따른 화면 분기), `screens/login_screen.dart`, `screens/signup_screen.dart`, `screens/family_setup_screen.dart`(가족 만들기/참여하기), `screens/home_screen.dart`(임시), `services/auth_service.dart`, `services/family_service.dart`
- 회원가입 → Firebase Auth 계정 생성 + `users/{uid}` 문서 생성, 로그인 → Firebase Auth, 가족 설정 → `createFamily`/`joinFamily` Cloud Function 호출까지 연결
- `dart analyze lib` 통과(정적 분석 이상 없음). **단, 실제 기기/시뮬레이터에서 `flutter run`으로 동작 검증은 안 됨** — Xcode/에뮬레이터 환경이 없어서 직접 확인 필요
- 리포 루트 `.gitignore`의 Python용 `lib/` 규칙 때문에 mira의 새 Dart 파일들이 git에서 안 잡히는 문제 발견 → `Frontend/mira/.gitignore`에 예외 규칙 추가로 해결 (familyapp에 이미 있던 것과 동일한 패턴)

### 보안
- `Backend/API/claude API 연동.ipynb`에 평문으로 커밋돼 있던 ngrok 토큰 제거 → Colab Secrets(`NGROK_AUTHTOKEN`)로 이전
- 노출됐던 토큰 재발급 완료

## 미완료

### Firebase 연결 마무리
- [ ] Android 앱 등록 (패키지명 `com.a1hajo.mira`) → `google-services.json` 배치 + Gradle에 google-services 플러그인 연결 + `firebase_options.dart`에 android 옵션 추가
- [ ] Web 앱 등록 → 설정값 확보 → `firebase_options.dart`에 web 옵션 추가
- [ ] **`firebase deploy --only functions`로 `createFamily`/`joinFamily` 실제 배포** — 배포 전까지는 mira 앱에서 가족 만들기/참여하기를 눌러도 함수가 없어서 실패함
- [ ] mira를 실제 기기/시뮬레이터에서 `flutter run`으로 회원가입 → 로그인 → 가족 생성/참여 전체 플로우 수동 검증

### AI 서버
- [ ] 파인튜닝된 감정 분류 모델(klue/bert-base)을 Hugging Face Hub(private repo)에 업로드 → `EMOTION_MODEL_PATH`에 반영 (현재는 파인튜닝 안 된 기본 모델이라 `ai_emotion` 결과가 무의미함)
- [ ] 실제 배포처 결정 및 배포 (현재는 로컬 실행만 확인됨)

### Firestore / Cloud Functions
- [ ] rules, functions 에뮬레이터 검증
- [ ] 나머지 로직 구현: 정원 진행도 트랜잭션, 알림 fan-out, 데일리 질문 생성(스케줄), 타임캡슐 "1년 전 오늘" 조회
- [ ] 실제 배포 (`firebase deploy`)
- [ ] `Frontend/mira` 화면 코드가 들어오면 스키마 재검토

### 프론트 ↔ 백엔드 실연동 (남은 부분)
- [ ] 캘린더/타임캡슐/정원/알림 등 나머지 화면 — mira에 아직 화면 자체가 없어서 Firestore 연동 작업 자체가 미시작
- [ ] familyapp 쪽은 그대로 미연동 상태 (mira가 최종 프론트로 정리됨에 따라 familyapp 작업은 보류)

### 기타
- [ ] 각자 `.env` 필요 (`Backend/ai-server/.env` — Gemini API 키는 개인/팀 계정으로 각자 발급)
