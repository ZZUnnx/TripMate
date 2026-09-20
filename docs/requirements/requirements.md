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
