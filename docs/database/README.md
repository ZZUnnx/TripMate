# ERD

# TripMate DB 설계

## ERD

예정 테이블

- users
- trips
- trip_members
- chat_messages
- schedule_candidates
- schedules

---

1. users (회원정보)
- id                BIGINT PK
- email             VARCHAR(100) UNIQUE
- password          VARCHAR(255)
- nickname          VARCHAR(50)
- created           DATETIME
- updated           DATETIME

2. trips (여행방)
- id                BIGINT PK
- title             VARCHAR(100)
- destination       VARCHAR(100)
- start_date        DATE
- end_date          DATE
- owner_id          BIGINT FK → users.id
- created           DATETIME
- updated           DATETIME

3. trip_members (여행 참여 인원)
- id                BIGINT PK
- trip_id           BIGINT FK → trips.id
- user_id           BIGINT FK → users.id
- role              VARCHAR(20)
- joined_at         DATETIME

4. chat_message (채팅 내용)
- id                BIGINT PK
- trip_id           BIGINT FK-> trips.id
- sender_id         BIGINT FK-> users.id
- message           TEXT
- message_type      VARCHAR(20)
- created_at        DATETIME

5. schedule_candidates (일정 후보)
- id                BIGINT PK
- trip_id           BIGINT FK → trips.id
- title             VARCHAR(100)
- category          VARCHAR(20)
- schedule_date     DATE
- schedule_time     TIME
- place_name        VARCHAR(100)
- url               TEXT
- status            VARCHAR(20)
- source_message_id BIGINT NULL
- created_at        DATETIME

6. schedule (확정된 일정)
- id                BIGINT PK
- trip_id           BIGINT FK → trips.id
- title             VARCHAR(100)
- category          VARCHAR(30)
- schedule_date     DATE
- start_date        TIME
- end_time          TIME
- place_name        VARCHAR(100)
- address           VARCHAR(255)
- url               TEXT
- memo              TEXT
- created_by        BIGINT FK → users.id
- created_at        DATETIME
- updated_at        DATETIME
