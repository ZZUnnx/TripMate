# TripMate 아키텍처와 실행 구성

기준일: **2026-11-11**. 현재 저장소 소스 기준입니다. 과거 문서에 기록된 원격 서버 구성과 이번에 확인한 사실을 구분합니다.

## 전체 흐름

```text
Flutter 앱
  screens / widgets: 화면과 입력
  controllers / providers: 조회·저장·상태·로그인 관리
  services: REST / WebSocket 통신
      ↓
Spring Boot 서버
  Controller: 요청 수신·토큰 확인
  Service: 여행 권한·업무 규칙·계산
  Repository / Entity: DB 접근과 매핑
      ↓
MySQL

AI 분석: 서버 → 여행 채팅 조회 → Gemini → 분석 JSON → 앱 검토
저장: 앱에서 선택·확인 → 일정 import / 지출 생성 API → MySQL
```

지도 API 연결은 현재 코드에 없습니다. UI의 지도 안내를 외부 지도 서비스 연동으로 해석하지 않습니다.

## 앱 계층

진입점은 [main.dart](../../frontend/lib/main.dart), 네 개 탭 전환은 [app_shell.dart](../../frontend/lib/screens/app_shell.dart)입니다. 세부 파일 구조는 [프론트 README](../../frontend/README.md)에 있습니다.

| 계층 | 책임 |
| --- | --- |
| `screens/` | 화면 조립·이동·컨트롤러 연결 |
| `widgets/` | 입력창·목록·카드 등 UI 부품 |
| `controllers/` | API 조회·저장, 로딩·실패·선택 상태 |
| `providers/auth_provider.dart` | 사용자 정보·토큰을 메모리와 SharedPreferences에 보관 |
| `services/` | HTTP JSON·STOMP 요청과 응답 처리 |
| `models/` | 여행·채팅·일정·정산 데이터 형식과 홈 집계 |

홈은 별도 홈 API 없이 여행 목록·여행별 일정·정산 목록을 조합합니다. 캘린더는 여행별 일정을 합칩니다. 정산 화면은 서버 집계·송금 계획을 사용합니다. 홈·캘린더·정산 탭 재진입 시 최신 데이터를 조회하며 홈은 아래로 당기기와 상세 복귀 시에도 갱신합니다.

## 연결 대상

| 용도 | 현재 앱 설정 | 근거 |
| --- | --- | --- |
| 일반 REST | `https://api.dwsdd.com` | [AuthService](../../frontend/lib/services/auth_service.dart) |
| STOMP | `wss://api.dwsdd.com/ws/chat` | [ChatSocketService](../../frontend/lib/services/chat_socket_service.dart) |
| AI 분석 | `https://api.dwsdd.com` | [AiService](../../frontend/lib/services/ai_service.dart), `AuthService.baseUrl` 공유 |

주소는 코드 상수입니다. 환경별 주소를 `--dart-define`으로 전환하는 구성은 없습니다. 로컬 서버를 켠 것만으로 앱이 그 서버를 사용하지 않습니다. 일반 REST와 AI는 `AuthService.baseUrl`을 공유합니다. 운영 배포 버전과 실제 DB는 미확인입니다.

## 서버·인증·저장

- Java 21 / Spring Boot 4.1.1. [실행 준비](../../backend/README.md)에 DB·JWT·Gemini 환경변수가 정리되어 있습니다.
- 여행·멤버·채팅 REST·일정·정산 Controller가 JWT를 검증하고 Service가 여행 접근 권한을 확인합니다.
- STOMP CONNECT는 JWT, 여행방 SUBSCRIBE는 접근 권한을 검사합니다. 메시지는 DB에 저장한 후 해당 여행 topic으로 전달합니다.
- AI 분석·테스트는 JWT 인증과 여행 소유자·참여자 권한 검사를 거친 후 Gemini를 호출합니다. 테스트에도 `tripId`가 필수입니다.
- JPA `ddl-auto=update`로 서버 기동 시 DB 스키마 갱신을 시도합니다. 실제 운영 스키마와 소스의 일치는 확인하지 않았습니다.
- 일정 import는 여행 행 잠금 아래 중복을 비교합니다. 지출의 중복 확인은 앱 조회·비교이며 서버의 동시 중복 방지 기능과 다릅니다.
- 여러 일정·지출 저장은 별도 요청입니다. 전체를 한 번에 취소·확정하는 트랜잭션이 아니며 일부 성공 후 재시도할 수 있습니다.

## DB 구성

여행방은 `trips` 자체를 사용하며 별도 `chat_rooms` Entity는 없습니다. 소유자는 `trips.owner_id`, 추가 멤버는 `trip_members`로 관리합니다. 채팅·일정·지출은 여행 ID에 연결됩니다.

`schema.sql`, `seed.sql`은 주석 초안이고 정산 추가 SQL만 실행 가능한 형태입니다. 현재 모델과 적용 범위는 [DB 구조](../database/README.md), [SQL 안내](../../database/README.md)를 참고하세요.

## 원격 서버에 관한 과거 기록

이전 문서에는 Ubuntu 서버, `/srv/tripmate/app`, SSH·Tailscale, Docker Compose의 MySQL 8.4.11 및 `127.0.0.1:3306` 바인딩이 기록되어 있었습니다. **이번 점검에서는 이 구성을 원격에서 확인하지 않았습니다.** 현재 저장소에는 Dockerfile·Compose 배포 파일이 없으므로 위 기록을 재현 가능한 배포 명세나 현재 실행 상태로 간주하지 않습니다.

## 확인한 실행 결과와 한계

2026-11-11 기준 Flutter 전체 정적 분석 문제 없음, 프론트 테스트 58개·백엔드 DB 독립 단위 테스트 13개가 통과했습니다. 인증 없는 운영 주소 여행·정산 GET은 각각 401을 반환했습니다.

인증 후 DB 저장·조회, 실제 STOMP 송수신, Gemini 응답, 서버 기동·배포 및 실기기 실행은 확인하지 않았습니다. 서버 기동과 DB 변경은 수행하지 않았습니다. [기능별 현황](../requirements/requirements.md)을 참고하세요.
