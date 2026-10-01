# ERD

[svg](https://github.com/ZZUnnx/TripMate/tree/main/docs/database#erd)

# TripMate DB 설계

[svg](https://github.com/ZZUnnx/TripMate/tree/main/docs/database#tripmate-db-%EC%84%A4%EA%B3%84)

## ERD

[svg](https://github.com/ZZUnnx/TripMate/tree/main/docs/database#erd-1)

### 예정 테이블

* users
* trips
* trip_members
* chat_messages
* schedule_candidates
* schedules

---

## 1. users (회원 정보)

| 컬럼       | 타입           | 제약조건               | 설명    |
| -------- | ------------ | ------------------ | ----- |
| id       | BIGINT       | PK, AUTO_INCREMENT | 회원 ID |
| email    | VARCHAR(100) | UNIQUE, NOT NULL   | 이메일   |
| password | VARCHAR(255) | NOT NULL           | 비밀번호  |
| nickname | VARCHAR(50)  | NOT NULL           | 닉네임   |
| created  | DATETIME     | NOT NULL           | 생성 시간 |
| updated  | DATETIME     | NOT NULL           | 수정 시간 |

---

## 2. trips (여행방)

| 컬럼          | 타입           | 제약조건                    | 설명      |
| ----------- | ------------ | ----------------------- | ------- |
| id          | BIGINT       | PK, AUTO_INCREMENT      | 여행방 ID  |
| title       | VARCHAR(100) | NOT NULL                | 여행방 제목  |
| destination | VARCHAR(100) | NOT NULL                | 여행 목적지  |
| start_date  | DATE         | NOT NULL                | 여행 시작일  |
| end_date    | DATE         | NOT NULL                | 여행 종료일  |
| owner_id    | BIGINT       | FK → users.id, NOT NULL | 여행방 생성자 |
| created     | DATETIME     | NOT NULL                | 생성 시간   |
| updated     | DATETIME     | NOT NULL                | 수정 시간   |

---

## 3. trip_members (여행 참여 인원)

| 컬럼        | 타입          | 제약조건                    | 설명       |
| --------- | ----------- | ----------------------- | -------- |
| id        | BIGINT      | PK, AUTO_INCREMENT      | 참여 정보 ID |
| trip_id   | BIGINT      | FK → trips.id, NOT NULL | 여행방 ID   |
| user_id   | BIGINT      | FK → users.id, NOT NULL | 회원 ID    |
| role      | VARCHAR(20) | NOT NULL                | 여행방 내 역할 |
| joined_at | DATETIME    | NOT NULL                | 참여 시간    |

### 제약조건

* 동일 사용자가 동일 여행방에 중복 참여하지 않도록 `(trip_id, user_id)` UNIQUE 설정

---

## 4. chat_messages (채팅 내용)

| 컬럼           | 타입          | 제약조건                    | 설명        |
| ------------ | ----------- | ----------------------- | --------- |
| id           | BIGINT      | PK, AUTO_INCREMENT      | 채팅 메시지 ID |
| trip_id      | BIGINT      | FK → trips.id, NOT NULL | 여행방 ID    |
| sender_id    | BIGINT      | FK → users.id, NOT NULL | 메시지 작성자   |
| message      | TEXT        | NOT NULL                | 메시지 내용    |
| message_type | VARCHAR(20) | NOT NULL                | 메시지 타입    |
| created_at   | DATETIME    | NOT NULL                | 메시지 생성 시간 |

---

## 5. schedule_candidates (일정 후보)

| 컬럼                | 타입           | 제약조건                        | 설명             |
| ----------------- | ------------ | --------------------------- | -------------- |
| id                | BIGINT       | PK, AUTO_INCREMENT          | 일정 후보 ID       |
| trip_id           | BIGINT       | FK → trips.id, NOT NULL     | 여행방 ID         |
| title             | VARCHAR(100) | NOT NULL                    | 일정 제목          |
| category          | VARCHAR(20)  | NULL                        | 일정 카테고리        |
| schedule_date     | DATE         | NULL                        | 일정 날짜          |
| schedule_time     | TIME         | NULL                        | 일정 시간          |
| place_name        | VARCHAR(100) | NULL                        | 장소명            |
| url               | TEXT         | NULL                        | 관련 URL         |
| status            | VARCHAR(20)  | NOT NULL                    | 후보 상태          |
| source_message_id | BIGINT       | FK → chat_messages.id, NULL | 후보가 추출된 채팅 메시지 |
| created_at        | DATETIME     | NOT NULL                    | 생성 시간          |

---

## 6. schedules (확정된 일정)

> 2026-10-01 구현 기준: 현재 JPA 엔티티와 API는 `scheduled_date`, `scheduled_time`, `place_name`, `description`, `sort_order` 필드를 사용한다. 아래 표의 `schedule_date`, `start_time`, `end_time`, `address`, `memo`, `created_by`는 초기 설계안이며, 개인 일정/상세 장소 관리 확장 시 재정리한다.

| 컬럼            | 타입           | 제약조건                    | 설명       |
| ------------- | ------------ | ----------------------- | -------- |
| id            | BIGINT       | PK, AUTO_INCREMENT      | 일정 ID    |
| trip_id       | BIGINT       | FK → trips.id, NOT NULL | 여행방 ID   |
| title         | VARCHAR(100) | NOT NULL                | 일정 제목    |
| category      | VARCHAR(30)  | NULL                    | 일정 카테고리  |
| schedule_date | DATE         | NOT NULL                | 일정 날짜    |
| start_time    | TIME         | NULL                    | 일정 시작 시간 |
| end_time      | TIME         | NULL                    | 일정 종료 시간 |
| place_name    | VARCHAR(100) | NULL                    | 장소명      |
| address       | VARCHAR(255) | NULL                    | 장소 주소    |
| url           | TEXT         | NULL                    | 관련 URL   |
| memo          | TEXT         | NULL                    | 일정 메모    |
| created_by    | BIGINT       | FK → users.id, NOT NULL | 일정 생성자   |
| created_at    | DATETIME     | NOT NULL                | 생성 시간    |
| updated_at    | DATETIME     | NOT NULL                | 수정 시간    |

---

## 테이블 관계

* `users` 1 : N `trips`
* `users` N : M `trips` (`trip_members`를 통해 연결)
* `trips` 1 : N `chat_messages`
* `trips` 1 : N `schedule_candidates`
* `trips` 1 : N `schedules`
* `chat_messages` 1 : N `schedule_candidates`
* `users` 1 : N `schedules`

---

## 삭제 정책

* 여행방(`trips`) 삭제 시 해당 여행방의 `trip_members`, `chat_messages`, `schedule_candidates`, `schedules` 데이터도 함께 삭제
* 일정 후보의 원본 채팅이 삭제된 경우 `source_message_id`는 `NULL` 처리
* 여행방 소유자 및 일정 생성자와 같이 주요 데이터의 작성자를 참조하는 경우 임의 삭제를 방지
