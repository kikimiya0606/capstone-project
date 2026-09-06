# Firestore 스키마

familyapp 화면들이 실제로 쓰는 필드 기준으로 설계함 (역할 4종 고정: 아빠/엄마/아들/딸).

## `users/{userId}` (userId = Firebase Auth uid)
| 필드 | 타입 | 비고 |
|---|---|---|
| name | string | |
| birthday | string | `yyyy-MM-dd`로 통일 (기존 화면들은 형식이 제각각이었음) |
| photoURL | string? | |
| familyId | string? | = 가족 초대 코드 |
| role | string? | 아빠/엄마/아들/딸 중 하나 |
| createdAt | timestamp | |

### `users/{userId}/settings/preferences`
notificationEnabled, screenLock, vibration (bool)

### `users/{userId}/notifications/{notificationId}`
type(`schedule`/`todayQuestion`/`familyAnswer`), title, message, createdAt(timestamp), isRead(bool), relatedId(string?) — 생성은 Cloud Functions에서만.

## `families/{familyId}`
문서 id 자체가 초대 코드(8자리, invite_screen의 "내 코드"와 동일한 것).

| 필드 | 타입 | 비고 |
|---|---|---|
| members | map<uid, role> | 최대 4명, role은 가족당 1명씩만 |
| createdAt | timestamp | |

쓰기는 전부 `createFamily`/`joinFamily` Cloud Function을 통해서만.

### `families/{familyId}/events/{eventId}`
title, memo, date(`yyyy-MM-dd`), alarmOption, authorUserId, authorRole, isHoliday(bool) — 캘린더는 가족 공용이므로 멤버 전원 read/write.

### `families/{familyId}/moods/{moodId}`
홈 화면 "오늘 기분" 기록. userId, role, moodTag(#기쁨 등 6종), moodText, date — 생성만 가능(수정/삭제 불가), 작성자 본인 uid로만 생성 가능.

### `families/{familyId}/dailyQuestions/{questionId}`
text, date — 생성은 스케줄 Cloud Function에서만.

#### `.../dailyQuestions/{questionId}/answers/{userId}`
text, submittedAt — 문서 id를 userId로 고정해서 "가족 전원 답변 여부"를 멤버 수와 answers 개수 비교만으로 판단 가능하게 함. 본인 uid 문서만 write 가능.

### `families/{familyId}/garden` (단일 문서, 가족 전체 공유)
cookieCount(int), progress(0~1 float), level(int), updatedAt — mood/answer 제출 시 Cloud Function이 트랜잭션으로 갱신(클라이언트 직접 쓰기 금지, race condition 방지).

## 타임캡슐
별도 컬렉션 없음 — `moods`/`answers`를 date 기준(오늘 - 1년)으로 조회해서 구성. 화면에서 필요한 "1년 전 오늘" 쿼리를 Cloud Function으로 감쌀지, 클라이언트에서 직접 range query할지는 추후 결정.

## 공휴일
`holidays/{date}` (읽기 전용, 공용) — 사용자 쓰기 불가. 시딩 스크립트나 공휴일 API 연동은 추후.
