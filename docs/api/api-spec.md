# TripMate API 명세

기준일: **2026-11-11**. `backend/src/main/java/com/tripmate/backend/`의 Controller·DTO·Service 기준입니다. 응답 예시는 형식 설명용이며 운영 데이터가 아닙니다. 이 문서는 배포 버전 일치를 보장하지 않습니다.

## 연결 주소와 인증

- REST 경로 접두사: `/api`, JSON 요청·응답. 회원가입 응답은 문자열입니다.
- Flutter 일반 API: `https://api.dwsdd.com` (`frontend/lib/services/auth_service.dart`).
- Flutter AI 분석: 공통 `AuthService.baseUrl`의 `https://api.dwsdd.com` (`frontend/lib/services/ai_service.dart`).
- 인증 대상은 `Authorization: Bearer <accessToken>`을 전달합니다. Controller의 `AuthUserIdResolver`가 JWT를 검증합니다.
- 여행·멤버·채팅·일정·정산은 소유자 또는 여행 참여자 접근을 검사합니다.
- AI 분석·테스트도 JWT 인증 및 여행 소유자·참여자 접근 검사를 수행합니다. 테스트 API는 `tripId` 쿼리 파라미터가 필수입니다.
- 전역 예외 핸들러는 중복 이메일·로그인 불일치 등의 `IllegalArgumentException`과 잘못된 입력을 400, `SecurityException`을 403으로 반환합니다. 기존 `ResponseStatusException`의 상태(토큰 누락·무효 401, 리소스 없음·여행 접근 불가 404 등)는 유지합니다.
- 위 오류는 `{status, error, message, path}` JSON으로 반환합니다. 예: `{"status":400,"error":"Bad Request","message":"이미 사용 중인 이메일입니다.","path":"/api/auth/signup"}`.

## 구현된 REST API

아래에서 인증 `필요`는 Bearer JWT 검증을 뜻합니다.

| 기능 | Method | 경로 | 인증 | 성공 응답 |
| --- | --- | --- | --- | --- |
| 회원가입 | POST | `/api/auth/signup` | 없음 | 200, 문자열 |
| 로그인 | POST | `/api/auth/login` | 없음 | 200, 로그인 정보 |
| 여행 목록 | GET | `/api/trips` | 필요 | 200, Trip 배열 |
| 여행 생성 | POST | `/api/trips` | 필요 | 201, Trip |
| 멤버 목록 | GET | `/api/trips/{tripId}/members` | 필요 | 200, Member 배열 |
| 멤버 추가 | POST | `/api/trips/{tripId}/members` | 필요 | 201, Member |
| 채팅방 목록 | GET | `/api/chat/rooms` | 필요 | 200, ChatRoom 배열 |
| 메시지 이력 | GET | `/api/chat/rooms/{tripId}/messages` | 필요 | 200, Message 배열 |
| REST 메시지 전송 | POST | `/api/chat/rooms/{tripId}/messages` | 필요 | 201, Message |
| 일정 목록 | GET | `/api/trips/{tripId}/schedules` | 필요 | 200, Schedule 배열 |
| 일정 생성 | POST | `/api/trips/{tripId}/schedules` | 필요 | 201, Schedule |
| 일정 중복 확인·생성 | POST | `/api/trips/{tripId}/schedules/import` | 필요 | 201 새 항목 / 200 기존 항목 |
| 일정 수정 | PATCH | `/api/schedules/{scheduleId}` | 필요 | 200, Schedule |
| 일정 삭제 | DELETE | `/api/schedules/{scheduleId}` | 필요 | 204 |
| 참여 여행 정산 목록 | GET | `/api/settlements` | 필요 | 200, Settlement 배열 |
| 여행 정산 상세 | GET | `/api/trips/{tripId}/settlement` | 필요 | 200, Settlement |
| 지출 생성 | POST | `/api/trips/{tripId}/expenses` | 필요 | 201, 본문 없음 |
| 지출 수정 | PATCH | `/api/expenses/{expenseId}` | 필요 | 204 |
| 지출 삭제 | DELETE | `/api/expenses/{expenseId}` | 필요 | 204 |
| 정산 완료 상태 변경 | PATCH | `/api/trips/{tripId}/settlement` | 필요 | 204 |
| AI 채팅 분석 | POST | `/api/trips/{tripId}/ai/analyze` | 필요 | 200, `{items: [...]}` |
| Gemini 테스트 | GET | `/api/ai/test?tripId=...&message=...` | 필요 | 200, 응답 문자열 |

## 인증

회원가입 본문:

```json
{"email":"user@example.com","password":"password123","nickname":"여행자"}
```

이메일·비밀번호·닉네임은 필수이며 이메일 형식, 비밀번호 최소 6자, 닉네임 최대 50자를 검증합니다. 성공 응답은 `회원가입 성공` 문자열입니다. 중복 이메일은 Service에서 거부합니다.

로그인 본문은 `email`, `password`이며 성공 응답 필드는 `id`, `email`, `nickname`, `accessToken`입니다. 서버 기본 JWT 만료는 24시간입니다. Refresh Token, 서버 로그아웃·토큰 폐기 API는 없습니다. 앱 로그아웃은 로컬 로그인 정보를 삭제합니다.

근거: [AuthController](../../backend/src/main/java/com/tripmate/backend/auth/AuthController.java), [AuthService](../../backend/src/main/java/com/tripmate/backend/auth/AuthService.java), [설정](../../backend/src/main/resources/application.properties).

## 여행·멤버

여행 생성 본문:

```json
{"title":"부산 여행","destination":"부산","startDate":"2026-11-20","endDate":"2026-11-22"}
```

`title`은 필수·최대 100자이고 나머지는 선택입니다. 여행지는 최대 100자입니다. 종료일이 시작일보다 빠른 요청은 Service에서 거부합니다. 현재 앱 생성 화면은 제목만 받습니다.

Trip 응답: `id`, `title`, `destination`, `startDate`, `endDate`, `ownerId`, `createdAt`. 목록에는 소유하거나 참여하는 여행이 포함됩니다.

멤버 추가 본문은 `{"email":"member@example.com","role":"MEMBER"}`입니다. `role` 생략 시 MEMBER이며 현재 구현은 가입된 사용자를 즉시 추가합니다. 초대 메일·수락 대기 절차는 없습니다. 소유자·기존 멤버 중복 추가를 거부합니다. 여행 접근 가능한 사용자가 요청할 수 있으며 소유자 전용으로 제한되어 있지 않습니다.

Member 응답: `userId`, `email`, `nickname`, `role`, `owner`, `joinedAt`. 목록은 소유자와 참여 멤버를 포함합니다.

근거: [trip 패키지](../../backend/src/main/java/com/tripmate/backend/trip/).

## 채팅과 WebSocket/STOMP

REST 메시지 전송 본문은 `{"content":"내일 오전에 만나요"}`입니다. 이력은 전송 시간 순으로 조회합니다.

Message 응답: `id`, `tripId`, `senderId`, `senderNickname`, `content`, `sentAt`, `mine`. 실시간 수신 시 앱은 현재 사용자 ID와 발신자 ID로 내 메시지 여부를 판별합니다.

ChatRoom 응답: `tripId`, `title`, `destination`, `startDate`, `endDate`, `memberCount`, `lastMessage`, `lastSenderNickname`, `lastMessageAt`, `createdAt`, `unreadCount`, `pinned`, `aiSummaryAvailable`.

현재 `unreadCount=0`, `pinned=false`는 고정값입니다. `aiSummaryAvailable`은 저장된 요약 유무가 아니라 마지막 메시지 존재 여부입니다.

| 구분 | 경로·동작 |
| --- | --- |
| 연결 | `/ws/chat` (일반 API 주소 기준 `wss://api.dwsdd.com/ws/chat`) |
| 인증 | STOMP CONNECT 헤더에 `Authorization: Bearer <accessToken>` |
| 전송 | `/app/trips/{tripId}/messages`, 본문 `{"content":"..."}` |
| 구독 | `/topic/trips/{tripId}/messages` |
| 서버 처리 | 여행 접근 확인→DB 저장→해당 topic으로 Message 전달 |

앱은 메시지 이력은 REST, 새 메시지는 STOMP로 처리합니다. CONNECT의 JWT와 여행 topic SUBSCRIBE 권한을 검사합니다. 구독 수신 payload의 `mine`을 모든 사용자에게 공통인 값으로 신뢰해서는 안 됩니다.

근거: [ChatRoomController](../../backend/src/main/java/com/tripmate/backend/chat/ChatRoomController.java), [ChatStompController](../../backend/src/main/java/com/tripmate/backend/chat/ChatStompController.java), [STOMP 인증](../../backend/src/main/java/com/tripmate/backend/chat/StompAuthChannelInterceptor.java).

## 공유 일정

생성·수정·import는 같은 본문을 사용합니다. PATCH도 일부 필드만 보내는 방식이 아니라 아래 DTO의 필수값을 충족해야 합니다.

```json
{
  "title":"해운대 산책",
  "category":"관광",
  "scheduledDate":"2026-11-20",
  "scheduledTime":"10:00:00",
  "placeName":"해운대해수욕장",
  "url":"https://example.com/place",
  "description":"오전 산책",
  "sortOrder":1
}
```

필수: `title`(최대 100자), `scheduledDate`(YYYY-MM-DD). 선택: `category`(최대 30자), `scheduledTime`, `placeName`(최대 100자), `url`, `description`, `sortOrder`.

Schedule 응답: `id`, `tripId`, `tripTitle`, `tripDestination`, `tripStartDate`, `tripEndDate`, 위 일정 입력 필드, `createdAt`, `updatedAt`. 목록은 날짜·시간·정렬 순서·ID 기준입니다.

import 응답은 `{"created":true,"schedule":{...}}`입니다. 같은 여행에서 날짜·시간·제목·장소가 같은 일정이 있으면 `created:false`와 기존 일정을 반환합니다. 제목·장소 공백은 비교에서 제외합니다. 여행 행 잠금으로 생성 요청을 직렬화합니다. 일반 생성 API를 중복 제거 API로 간주하면 안 됩니다.

현재 개인 일정 전용 API는 없습니다. 서버 수정 API는 구현되었지만 앱의 수정 입력 화면은 연결되지 않았습니다.

근거: [ScheduleController](../../backend/src/main/java/com/tripmate/backend/schedule/ScheduleController.java), [ScheduleRequest](../../backend/src/main/java/com/tripmate/backend/schedule/dto/ScheduleRequest.java), [ScheduleService](../../backend/src/main/java/com/tripmate/backend/schedule/ScheduleService.java).

## 정산·지출

지출 생성·수정 본문:

```json
{
  "title":"숙소비",
  "amount":80000,
  "payerId":1,
  "expenseDate":"2026-11-20",
  "participantIds":[1,2],
  "placeName":"숙소"
}
```

- `title`: 필수, 최대 100자. `amount`: 필수 정수 원 단위, 1~1,000,000,000,000.
- `payerId`, `expenseDate`, 중복 없는 `participantIds`(1명 이상): 필수. 결제자·분담 대상은 여행 멤버여야 합니다.
- `placeName`: 선택, 최대 100자. PATCH는 위 입력 전체를 검증합니다.
- 완료 상태 본문: `{"completed":true}` 또는 `false`. 지출이 없으면 완료 표시를 거부합니다.
- 지출 추가·수정·삭제 시 기존 완료 상태를 해제합니다.

Settlement 응답:

| 필드 | 내용 |
| --- | --- |
| `tripId`, `title`, `startDate`, `endDate` | 여행 정보 |
| `completed`, `totalAmount`, `expenseCount` | 완료 여부, 지출 합계, 건수 |
| `myPayable`, `myReceivable` | 현재 사용자의 송금 계획상 보낼·받을 금액 |
| `members` | `{userId, nickname}` 배열 |
| `expenses` | `{id, title, amount, payerId, payerNickname, placeName, expenseDate, participantIds}` 배열 |
| `payers` | `{userId, nickname, paidAmount, shareAmount, balance, expenseCount}` 배열 |
| `places` | `{placeName, totalAmount, expenses}` 배열 |
| `transfers` | `{fromUserId, fromNickname, toUserId, toNickname, amount}` 배열 |

선택한 참여자끼리 균등 분담하고 나머지 원은 사용자 ID 오름차순으로 배분합니다. 실제 금융 송금은 수행하지 않습니다. 앱의 CSV 복사는 클립보드 동작이며 별도 내보내기 API는 없습니다.

근거: [SettlementController](../../backend/src/main/java/com/tripmate/backend/settlement/SettlementController.java), [ExpenseRequest](../../backend/src/main/java/com/tripmate/backend/settlement/ExpenseRequest.java), [SettlementResponse](../../backend/src/main/java/com/tripmate/backend/settlement/SettlementResponse.java).

## AI 분석과 사용자 확인 후 저장

분석 요청은 경로의 `tripId`를 사용하며 현재 별도 입력 본문이 없습니다. 서버가 해당 여행의 전체 채팅을 조회해 Gemini를 호출합니다.

응답의 `items` 각 항목: `type`(SCHEDULE / RESERVATION / SETTLEMENT), `title`, `date`, `endDate`, `time`, `placeName`, `amount`, `peopleCount`, `description`, `url`. 확인할 수 없는 값은 null을 반환하도록 프롬프트에 지시합니다. 외부 AI 응답의 유효성이나 정확성이 보장되는 계약은 아닙니다.

분석 API는 결과를 반환하며 후보 Entity에 저장하지 않습니다. 앱에서 날짜·제목 등이 유효한 일정·예약을 선택하면 일정 import API로 저장합니다. 예약 종료일은 메모에 저장합니다. 정산 항목과 금액이 있는 예약은 결제자·분담 대상·날짜 등을 확인한 뒤 지출 생성 API로 저장합니다. 일정·지출 저장은 별도 요청이며 하나의 원자적 트랜잭션이 아닙니다.

지출 중복 확인은 앱이 정산 목록을 재조회해 제목·금액·결제자·날짜·장소·분담 대상을 비교하는 방식입니다. 서버 지출 생성 API의 동시 요청 중복 방지 계약은 없습니다.

근거: [AI Controller](../../backend/src/main/java/com/tripmate/backend/ai/AiChatAnalysisController.java), [AI Service](../../backend/src/main/java/com/tripmate/backend/ai/AiChatAnalysisService.java), [앱 저장 Controller](../../frontend/lib/controllers/chat/ai_summary_controller.dart).

## 문서에 예정되었으나 없는 API

| 경로 | 현재 상태 |
| --- | --- |
| `GET /api/trips/{tripId}` | Controller 없음 |
| `GET /api/trips/{tripId}/schedule-candidates` | Controller·Repository 없음 |
| `PATCH /api/schedule-candidates/{candidateId}/approve` | Controller·승인 처리 없음 |

`ScheduleCandidate` Entity만 존재합니다. 현재 앱의 분석 결과 선택·일정 import와 영구 후보 보관·승인 이력은 다른 기능입니다. 별도 홈 API는 없으며 앱이 여행·일정·정산 API를 조합합니다.

## 실행 확인

2026-11-11 인증 없는 운영 주소의 여행·정산 목록 GET은 각각 401을 반환했습니다. 실제 로그인·저장·DB 조회·WebSocket·Gemini 통합 요청 및 현재 소스와 배포 버전의 일치는 확인하지 않았습니다. [검증 범위](../requirements/requirements.md)를 참고하세요.
