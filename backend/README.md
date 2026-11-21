# TripMate Backend

문서 기준일: **2026-11-11**. Java 21, Spring Boot 4.1.1, Gradle Wrapper 9.7.1, Spring Data JPA, MySQL을 사용합니다. WebSocket/STOMP 채팅과 외부 Gemini API 호출을 포함합니다.

## 실행 준비

실행 환경에 다음 값을 제공하세요. `application.properties`는 실행 디렉터리의 `.env` 파일을 선택적으로 읽습니다. `.env`는 자동 생성되지 않으며 비밀값은 저장소에 올리지 않습니다.

| 환경변수 | 용도 |
| --- | --- |
| `DB_URL` | MySQL JDBC URL |
| `DB_USERNAME` | DB 접속 사용자 |
| `DB_PASSWORD` | DB 접속 비밀번호 |
| `JWT_SECRET` | JWT 서명 키. jjwt가 요구하는 서명 키 길이를 만족해야 함 |
| `GEMINI_API_KEY` | Gemini API 키 |

```powershell
cd backend
.\gradlew.bat bootRun
```

Linux/macOS: `./gradlew bootRun`. 별도 포트 설정이 없으면 Spring Boot 기본 포트 8080을 사용합니다.

현재 `spring.jpa.hibernate.ddl-auto=update`이므로 서버 기동 시 연결된 DB의 스키마가 변경될 수 있습니다. 기동 대상 DB와 실제 스키마를 확인해야 합니다. [DB 안내](../database/README.md)를 참고하세요.

## 코드 구조

소스 루트: `src/main/java/com/tripmate/backend/`.

| 패키지 | 역할 |
| --- | --- |
| `auth`, `user` | 회원가입·로그인, BCrypt 비밀번호, JWT 발급·검증 |
| `trip` | 여행방 생성·조회, 여행 접근 권한, 멤버 추가·조회 |
| `chat` | REST 이력·메시지, STOMP 연결·구독 인증·메시지 전달 |
| `schedule` | 확정 일정 CRUD, 중복 확인 import, 후보 Entity |
| `ai` | DB 채팅 조회, Gemini 요청, 분석 JSON 변환 |
| `settlement` | 지출 CRUD, 균등 분담·송금 계획, 완료 상태 |

Controller는 요청을 받고, Service는 권한·업무 규칙을 처리하며, Repository는 JPA를 통해 DB를 조회·저장합니다. Entity는 테이블 매핑입니다.

## 인증과 권한

- 여행·멤버·채팅 REST·일정·정산 API는 Controller에서 `AuthUserIdResolver`를 호출해 Bearer JWT를 확인합니다. 공통 인증 필터를 사용하는 구조는 아닙니다.
- 여행 기능은 소유자 또는 참여자 접근 여부를 검사합니다. 멤버 추가는 접근 가능한 여행의 참여 사용자도 요청할 수 있는 현재 구현입니다.
- STOMP는 CONNECT에서 JWT, 여행방 SUBSCRIBE에서 접근 권한을 검사합니다. 메시지 저장 시에도 여행 접근 권한을 확인합니다.
- `jwt.expiration=86400000`: 현재 기본 토큰 만료는 24시간입니다. 원래 요구사항의 1시간과 다릅니다.
- AI 분석 `/api/trips/{tripId}/ai/analyze`와 `/api/ai/test`에는 현재 인증·여행 접근 검사가 없습니다. AI 분석 인증은 다른 API와 동일하게 적용된 상태가 아닙니다.
- 중복 이메일·로그인 불일치는 `IllegalArgumentException`을 던지며 이를 업무 오류 상태로 통일하는 전역 예외 처리 코드는 없습니다.

## 주요 동작

전체 경로·요청·응답은 [API 명세](../docs/api/api-spec.md)에 있습니다.

- 일정 import: 같은 여행의 날짜·시간·제목·장소가 같으면 기존 일정을 반환합니다. 제목·장소의 공백은 비교에서 제외합니다. 여행 행 잠금과 READ_COMMITTED 트랜잭션을 사용하며 일반 일정 생성도 같은 여행 잠금을 사용합니다.
- 정산: 선택한 참여자끼리 균등 분담하고 나머지 원은 사용자 ID 오름차순으로 배분합니다. 지출 변경 시 완료 상태가 해제됩니다. 송금 계획만 계산하며 실제 송금은 수행하지 않습니다.
- AI: 전체 채팅에서 일정·예약·정산 후보를 추출합니다. 코드에 지정된 모델은 `gemini-3.5-flash-lite`입니다. 실제 모델 응답 성공은 점검하지 않았습니다. 후보를 `schedule_candidates`에 저장하거나 승인 이력을 관리하는 API는 없습니다.
- 채팅방 목록의 `unreadCount=0`, `pinned=false`는 고정값이며, `aiSummaryAvailable`은 분석 저장 이력이 아니라 마지막 메시지 존재 여부로 설정됩니다.

## 검증

DB 연결 없이 실행 가능한 단위 테스트:

```powershell
.\gradlew.bat test --tests 'com.tripmate.backend.settlement.*' --tests 'com.tripmate.backend.schedule.ScheduleImportTest'
```

2026-11-11에 같은 범위를 `--offline` 옵션으로 실행해 총 13개가 통과했습니다. `--offline`은 의존성이 캐시되어 있어야 합니다. 테스트는 정산 계산·서비스와 일정 import를 검증합니다.

`BackendApplicationTests`는 `@SpringBootTest`를 사용하므로 전체 `test` 실행은 애플리케이션 설정·DB 연결이 필요할 수 있습니다. 이번 점검에서는 실행하지 않았습니다.

## 배포 확인 범위

2026-11-11 `https://api.dwsdd.com/api/trips`, `/api/settlements`에 인증 없는 GET 요청을 보내 각각 401 응답을 확인했습니다. 인증 후 데이터 처리, 현재 소스와 배포 버전의 일치, 실제 DB 스키마는 확인하지 않았습니다. 이 문서 갱신은 서버 배포·DB 변경을 포함하지 않습니다.
