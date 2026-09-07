# 3번·4번: 가족 돌봄 자동 배정과 강아지 대화

브랜치: `feat/daily-care-pet-dialogue`

## 구현 범위

- 한국 시간 매일 08:00에 가족 구성원마다 밥 주기/목욕/놀기/재우기 중 하나를 무작위 배정한다. 최대 4명에게 서로 다른 행동을 배정하며, 4명 미만이면 행동 일부만 배정된다. 다음 날 같은 행동이 다시 배정될 수도 있다.
- 오전 8시부터 다음 날 오전 8시 전까지 같은 돌봄 날짜를 사용한다. 기기 시간대가 달라도 기준은 한국 시간이다.
- 스케줄 실행 누락이나 새 가족 생성 시 첫 조회에서 서버가 배정을 보충한다. 트랜잭션으로 기존 배정과 완료 기록을 보존하고, 당일 가입자는 남은 행동을 받는다.
- 기존 수동 선택/변경 UI를 자동 배정 표시로 교체했다. 배정된 본인 행동을 강아지 화면에서 실행하면 완료 처리한다. 다른 행동은 강아지와 놀 수 있지만 본인의 배정 완료로 계산되지 않는다.
- 밥 12시, 목욕·놀기 18시, 재우기 21시 이후 미완료 담당자를 기준으로 팝업과 말풍선을 표시한다. 예: 엄마에게 밥이 배정됐다면 `엄마 기다리는 중!`으로 표시한다. 자정부터 오전 8시까지 자동 팝업을 쉬며, 여러 행동이 밀렸으면 밥→목욕→놀기→재우기 순서로 안내한다.
- 자동 팝업은 홈의 강아지 영역 또는 전체 강아지 화면이 활성 상태일 때 확인한다. 같은 기기·계정·가족·날짜·행동에서는 한 번 표시한다. 앱이 닫혀 있을 때 OS 푸시를 보내는 기능은 포함하지 않는다.
- 머리 위 `!` 또는 `강아지와 대화하기`를 누르면 Gemini 기반 대화창을 연다. 최근 6회 대화와 현재 가족 역할별 돌봄 상태만 전송한다. 일기 내용은 보내지 않는다. 대화 기록은 창을 닫으면 사라진다.
- AI 응답이 실제 돌봄 배정/완료를 변경하지 않는다. 키나 서버 연결이 없으면 실패 안내를 표시하고 작성한 메시지를 보존한다.

## 언어와 담당 파일

새 언어 도입은 없다. 기존 Dart, JavaScript, Python을 사용한다.

| 구분 | 파일 | 역할 |
|---|---|---|
| JavaScript | `Backend/functions/daily-care.js`, `care-functions.js` | 무작위 배정, 한국 날짜, 스케줄, 인증된 완료 처리 |
| Firestore 규칙 | `Backend/firestore.rules` | 클라이언트 직접 배정 변경 차단 |
| Dart | `Frontend/mira/lib/services/daily_care_service.dart` | 서버 호출, 실시간 상태, 날짜 전환 |
| Dart | `Frontend/mira/lib/dog_room/screens/family_dog_room.dart` | 가족 상태와 기존 강아지 화면 연결 |
| Dart | `Frontend/mira/lib/dog_room/models/care_reminder.dart`, `widgets/pet_chat_sheet.dart` | 알림 판단, 대화창 |
| Python | `Backend/ai-server/app/{main,schemas,gemini_service}.py` | `/pet-chat` 입력 검증과 Gemini 호출 |

별도 학습 데이터나 파인튜닝은 필요하지 않다. 배정·알림은 일반 프로그램 로직이며, 자연스러운 강아지 대화에만 기존 생성 모델을 사용한다.

## API와 저장 형식

`families/{familyId}/dailyCare/{YYYY-MM-DD}` 형식은 기존과 동일하다.

```json
{
  "user-uid": {"action": "🍚 밥 주기", "completedAt": null}
}
```

- `ensureDailyCare({familyId})` → `{dateId}`. Firebase Auth 토큰과 가족 문서의 실제 멤버십을 확인한다.
- `completeDailyCare({familyId, action})` → `{completed}`. UID는 인증 토큰에서 결정한다. 중복 완료는 false이고 서버 타임스탬프가 덮어써지지 않는다.
- `POST /pet-chat`: `{message, care_context, history: [{role: "user" | "model", text}]}` → `{reply}`. 메시지 500자, 문맥 2,000자, 이력 12개로 제한한다.

기존 수동 선택 기록은 당일 유지한다. 규칙 배포 이후 구버전 앱의 직접 선택·완료 쓰기는 차단되므로 새 앱과 서버·규칙을 함께 적용해야 한다.

## 실행과 배포

1. 프로젝트 루트에서 대상 Firebase 프로젝트를 확인한다. `Backend/functions`에서 `npm ci`를 실행한다.
2. 아래 명령으로 새 함수와 규칙을 배포한다. 기존 함수는 함께 배포할 필요가 없다.

```sh
firebase deploy --only functions:ensureDailyCare,functions:completeDailyCare,functions:assignDailyCare,firestore:rules
```

3. `Backend/ai-server`의 기존 가상환경과 requirements를 사용한다. 서버 환경에 `GEMINI_API_KEY`, 사용 가능한 `GEMINI_MODEL`, 앱 주소에 맞는 `CORS_ORIGINS`를 설정한다. 키는 앱 코드나 Git에 넣지 않는다.

```sh
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

4. `Frontend/mira`에서 앱을 실행한다. Android 에뮬레이터는 `http://10.0.2.2:8000`, 실기기는 접속 가능한 개발 PC 주소를 사용한다.

```sh
flutter run --dart-define=AI_SERVER_BASE_URL=http://localhost:8000
```

Firebase 스케줄 함수는 배포 프로젝트의 결제/Cloud Scheduler 설정이 필요하다. 이 브랜치 작업에서는 실제 클라우드 배포와 모델 호출을 수행하지 않는다. AI 서버의 기존 공개 API 구조를 따르므로 외부 운영 배포 전에는 팀의 인증·호출 제한 정책을 적용해야 한다.

공식 참고: [Firebase 스케줄 함수](https://firebase.google.com/docs/functions/schedule-functions), [Gemini 시스템 지시](https://ai.google.dev/gemini-api/docs/text-generation).

## 검증

### 지금 로컬에서 직접 확인하기

실제 가족 데이터 대신 독립적인 `demo-mira-care` 에뮬레이터를 사용하는 실행 경로를 추가했다.

```powershell
# 터미널 1: 프로젝트 루트
firebase.cmd emulators:start --config firebase.emulators.json --project demo-mira-care --only auth,firestore,functions

# 터미널 2: 프로젝트 루트 (연동 검증 + 테스트 계정/배정 준비)
cd Backend/functions
node care-smoke.cjs

# 터미널 3: 프로젝트 루트
cd Frontend/mira
flutter run -d chrome --web-port 5173 --dart-define=USE_FIREBASE_EMULATORS=true
```

로그인: `dad@care.test` 또는 `mom@care.test`, 비밀번호: `CareTest123!`.
테스트 후 아빠에게 밥 주기, 엄마에게 놀기를 미완료로 남겨둔다. 해당 행동의 알림 시간 이후 홈에서 팝업과 느낌표를 확인하고, 담당 계정으로 행동을 실행하면 완료가 저장된다. 에뮬레이터 재시작 시 테스트 준비 명령을 다시 실행한다.

실제 에뮬레이터에서 동시 배정 요청 8개, 인증/가족 권한 검사, 본인 행동 완료, 중복 완료 방지, Firestore 읽기 허용·직접 쓰기 거절을 검증했다. 이 과정에서 Admin SDK의 FieldValue/FieldPath 접근 문제를 발견해 명시적인 `firebase-admin/firestore` import로 수정했다.

AI의 실제 Gemini 응답도 설정된 키로 검증했다. `/pet-chat`은 HTTP 200과 한국어 답변을 반환했으며, 약 37.7~48.8초가 걸렸다. 기존 앱의 30초 제한을 초과했으므로 90초로 조정하고 대기 중 안내와 오류 유형별 메시지를 추가했다. 에뮬레이터가 AI 응답을 대신 생성하지는 않는다. 외부 배포와 실제 스케줄 시간 실행은 별도 검증 대상이다.

기존 서버가 변경 전 `.env`를 계속 읽고 있다면 재시작해야 한다. 이번 확인에서는 새 서버를 8001번에 띄우고 아래 명령으로 앱을 5174번에 실행했다.

```powershell
# Backend/ai-server에서 실행 (테스트 가상환경 사용)
..\..\.tmp\care-test-env\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
# Frontend/mira에서 실행
flutter run -d chrome --web-port 5174 --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=AI_SERVER_BASE_URL=http://127.0.0.1:8001
```

`.env` 변경은 Python 코드 재로딩 대상이 아닐 수 있으므로 키 변경 뒤에는 서버를 종료하고 다시 실행한다. `check_pet_config.py --chat`으로 설정된 모델 접근과 실제 응답을 확인할 수 있다(실제 API 호출 발생).

```sh
# Backend/functions
node --test
# Backend/ai-server (기존 개발 의존성 설치 후)
python -m pytest tests -q
# Frontend/mira
flutter analyze
flutter test
```

단위 테스트는 날짜 경계, 중복 없는 배정, 재시도·완료 기록 보존, 가족 권한 거절, 본인 행동만 완료, 알림 시간과 완료 후 해제, AI 요청 검증과 실패 응답을 다룬다. AI 응답과 Firebase callable 테스트는 모의 의존성을 사용한다.

배포 환경에서 최종 확인할 항목:

1. 같은 가족의 두 계정으로 로그인해 같은 배정이 보이는지 확인한다.
2. 담당 행동을 실행하면 두 화면에서 완료 상태가 반영되는지 확인한다.
3. 미완료 알림 시각에 올바른 담당자 이름이 나오고 재진입 시 같은 팝업이 반복되지 않는지 확인한다.
4. 오전 8시를 넘겨 화면을 열어두면 최대 약 1분 안에 새 날짜를 구독하는지 확인한다.
5. Gemini 서버 연결 성공/차단 각각에서 대화와 재시도 입력 보존을 확인한다.
6. Firebase Emulator에서 실제 Firestore 트랜잭션 충돌과 배포 규칙 거절을 검증한다. 로컬 모의 테스트는 이를 대신하지 않는다.
