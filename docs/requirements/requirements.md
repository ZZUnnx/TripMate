# 요구사항 정의서

## 핵심 기능
1. 회원가입 / 로그인
- 회원가입 시 유효성 검증
- 로그인 후 1시간동안 로그인 유지

2. 여행방 생성

3. 여행 멤버 초대

4. 실시간 채팅

5. 일정 등록 및 관리

6. AI 채팅 분석

7. AI 일정 후보 생성

8. 사용자 승인 후 일정 확정

9. 장소 및 지도 링크 관리

## 작업 기록

### 2026-09-20 실시간 채팅 STOMP 적용

- Spring Boot에 `spring-boot-starter-websocket` 의존성을 추가했다.
- 백엔드에 STOMP 엔드포인트 `/ws/chat`를 추가했다.
- 클라이언트 전송 destination은 `/app/trips/{tripId}/messages`로 정했다.
- 클라이언트 구독 destination은 `/topic/trips/{tripId}/messages`로 정했다.
- STOMP `CONNECT` 헤더의 JWT를 검증하고, 여행방 구독 시 접근 권한을 확인하도록 했다.
- 기존 REST 메시지 조회 API는 유지하고, 실시간 송수신만 STOMP로 처리하도록 Flutter 화면을 연결했다.

### 2026-10-01 캘린더 여행 공유 일정 연결

- AI 일정 후보 생성/승인 흐름은 제외하고 확정 일정 CRUD와 캘린더 조회 연결을 먼저 진행했다.
- 백엔드에 내 여행 목록 조회 API `GET /api/trips`를 추가했다.
- 백엔드에 확정 일정 API를 추가했다.
  - `GET /api/trips/{tripId}/schedules`
  - `POST /api/trips/{tripId}/schedules`
  - `PATCH /api/schedules/{scheduleId}`
  - `DELETE /api/schedules/{scheduleId}`
- 일정 API는 기존 여행방 접근 권한 확인 로직을 재사용해, 여행방 생성자 또는 멤버만 조회/등록/수정/삭제할 수 있도록 했다.
- Flutter에 여행/일정 모델과 `ScheduleService`를 추가했다.
- 캘린더 메인은 목데이터 대신 `GET /api/trips`와 여행별 일정 목록을 합쳐 월간 캘린더와 선택일 일정 목록을 표시하도록 연결했다.
- 캘린더 상세는 선택한 일정의 `tripId`를 기준으로 해당 여행의 전체 타임라인을 보여주도록 연결했다.
- 개인 일정 전용 API, 일정 추가/수정 UI 폼, 지도/정산 비용 연결은 후속 작업으로 남겼다.
