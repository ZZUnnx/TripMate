# TripMate 데이터 구조

기준일: **2026-11-11**. JPA Entity와 정산 SQL을 설명합니다. 실제 운영 DB의 DDL을 조회한 결과가 아닙니다. 별도 `@Column` 지정이 없는 camelCase 필드는 Spring Boot의 기본 명명 규칙에 따른 snake_case를 기준으로 표기합니다.

## 구조의 기준

- 소스: `backend/src/main/java/com/tripmate/backend/`의 `@Entity` 클래스
- 전체 생성 SQL: [schema.sql](../../database/schema.sql)은 주석 초안으로 아직 없음
- 초기 데이터: [seed.sql](../../database/seed.sql)은 주석 초안으로 아직 없음
- 정산 추가 SQL: [settlement.sql](../../database/settlement.sql)
- 서버 자동 갱신 설정: [application.properties](../../backend/src/main/resources/application.properties)의 `ddl-auto=update`

문서와 실제 DB 차이를 확인하기 전에는 컬럼 삭제 SQL을 실행하지 않습니다. 이 문서에는 과거의 중복 컬럼 삭제 명령을 유지하지 않습니다.

## 엔티티와 주요 필드

| 테이블 | 주요 필드·제약 | 근거 |
| --- | --- | --- |
| `users` | id PK, email(100·unique), password(255·BCrypt), nickname(50), created_at, updated_at | [User](../../backend/src/main/java/com/tripmate/backend/user/User.java) |
| `trips` | id PK, title(100·필수), destination(100·선택), start_date·end_date(선택), owner_id(필수), created_at, updated_at | [Trip](../../backend/src/main/java/com/tripmate/backend/trip/Trip.java) |
| `trip_members` | id PK, trip_id·user_id(필수·조합 unique), role(20), joined_at | [TripMember](../../backend/src/main/java/com/tripmate/backend/trip/TripMember.java) |
| `chat_messages` | id PK, trip_id·sender_id(필수), message(TEXT), message_type(20·기본 TEXT), created_at | [ChatMessage](../../backend/src/main/java/com/tripmate/backend/chat/ChatMessage.java) |
| `schedules` | id PK, trip_id, title(100), category(30), schedule_date, start_time, place_name(100), url, memo, sort_order, created_by, created_at, updated_at | [Schedule](../../backend/src/main/java/com/tripmate/backend/schedule/Schedule.java) |
| `schedule_candidates` | id PK, trip_id, title(100), category(30), scheduled_date, scheduled_time, place_name, url, description, status(20), created_at | [ScheduleCandidate](../../backend/src/main/java/com/tripmate/backend/schedule/ScheduleCandidate.java) |
| `expenses` | id PK, trip_id, title(100), amount(BIGINT), payer_id, place_name(100), expense_date | [Expense](../../backend/src/main/java/com/tripmate/backend/settlement/Expense.java) |
| `expense_participants` | expense_id·user_id, JPA ElementCollection, 조합 unique | [Expense](../../backend/src/main/java/com/tripmate/backend/settlement/Expense.java) |
| `settlement_statuses` | trip_id PK, completed_at(완료 해제 시 null) | [SettlementStatus](../../backend/src/main/java/com/tripmate/backend/settlement/SettlementStatus.java) |

여행 소유자는 `trips.owner_id`로 관리하며 멤버 목록 응답에서는 소유자와 `trip_members`를 합칩니다. 소유자가 항상 `trip_members`에 들어있다고 가정하지 않습니다. 별도 `chat_rooms` 테이블 Entity는 없습니다.

`ScheduleCandidate`는 Entity만 존재합니다. 조회·승인 API 및 Repository는 없으며 현재 Gemini 결과를 이 테이블에 저장하지 않습니다. 상태 기본값 PENDING은 Entity에 있지만 승인·거부 업무 흐름은 연결되지 않았습니다. 원문 채팅 연결용 `source_message_id`도 현재 Entity에는 없습니다.

## API 이름과 DB 컬럼 이름의 차이

| API·Java 필드 | 실제 매핑 컬럼 | 비고 |
| --- | --- | --- |
| 일정 `scheduledDate` | `schedules.schedule_date` | 명시적 Column 매핑 |
| 일정 `scheduledTime` | `schedules.start_time` | 종료 시간 입력 API 없음 |
| 일정 `description` | `schedules.memo` | 메모 |
| 일정 생성자 | `schedules.created_by` | User 관계 |
| 채팅 `content` | `chat_messages.message` | 본문 |
| 채팅 `sentAt` | `chat_messages.created_at` | 전송 시각 |
| 지출 `expenseDate` | `expenses.expense_date` | 지출일 |

현재 Schedule Entity에는 `end_time`, `address`가 없습니다. 후보의 `scheduled_date`와 확정 일정의 `schedule_date`를 혼동하지 않습니다. 예약 종료일은 별도 예약 테이블·종료일 컬럼 대신 일정 메모에 저장합니다.

## 관계

- User 1:N Trip: 여행 소유 관계
- User N:M Trip: `trip_members`를 통한 참여 관계
- Trip 1:N ChatMessage, Schedule, ScheduleCandidate, Expense
- User 1:N ChatMessage: 작성자
- User 1:N Schedule: 일정 생성자
- Expense 1:N `expense_participants`: 분담 사용자 ID 집합
- Trip별 정산 완료 기록: `settlement_statuses.trip_id`

`payer_id`, 분담 `user_id`, `settlement_statuses.trip_id`는 모두 JPA에서 관계 객체로 매핑된 것은 아닙니다. Service가 결제자·분담 대상의 여행 참여 여부를 검증합니다. [정산 SQL](../../database/settlement.sql)은 해당 ID들에 외래 키를 추가하며, 자동 생성된 실제 DB가 같은 제약을 가진다고 단정할 수 없습니다.

정산 SQL의 expense_participants는 두 ID의 복합 PK와 지출 삭제 CASCADE를 정의합니다. 이것을 전체 여행·계정 삭제 정책으로 확대 해석하면 안 됩니다. 현재 여행·계정 삭제 API는 없고, 모든 연관 데이터 일괄 삭제 정책도 운영 DB에서 확인하지 않았습니다.

## 비용과 완료 상태

- 금액은 원 단위 정수입니다. 입력 DTO는 1원 이상 1조원 이하를 검증합니다.
- 분담 인원만 저장하는 것이 아니라 실제 사용자 ID 집합을 보관합니다.
- 선택한 사용자끼리 균등 분담하고 나머지 원은 사용자 ID 오름차순으로 배분합니다.
- 송금 계획·결제자별·장소별 합계는 조회 시 계산하며 별도 송금 실행 기록이 아닙니다.
- 완료 시각을 저장하고 지출 변경 시 완료를 해제합니다.

## 검증 범위

이번 점검은 Entity·DTO·Repository·SQL 검토와 DB 독립 단위 테스트 기준입니다. 실제 컬럼·인덱스·외래 키, 이전 컬럼 잔존, DB 마이그레이션 이력·운영 데이터는 확인하지 않았습니다. 전체 DB 재현과 배포 절차는 [DB 안내](../../database/README.md), [아키텍처](../architecture/README.md)를 참고하세요.
