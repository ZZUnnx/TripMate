# Backend

Spring Boot 서버 프로젝트가 들어갈 폴더입니다.

권장 기능 패키지:
- auth
- user
- trip
- chat
- schedule
- ai
- global

## 정산 API

모든 정산 요청은 `Authorization: Bearer <token>`이 필요하며, 여행 소유자·참여자만 접근할 수 있습니다.

| 요청 | 경로 | 역할 |
|---|---|---|
| GET | `/api/settlements` | 참여 여행별 정산 목록 |
| GET | `/api/trips/{tripId}/settlement` | 지출·집계·송금 계획 |
| POST | `/api/trips/{tripId}/expenses` | 지출 등록 |
| PATCH / DELETE | `/api/expenses/{expenseId}` | 지출 수정 / 삭제 |
| PATCH | `/api/trips/{tripId}/settlement` | 완료 / 다시 열기 (`{"completed":true}` 또는 `false`) |

지출 입력: `title`, 정수 원 단위 `amount`, `payerId`, `expenseDate`(YYYY-MM-DD), `participantIds`, 선택 항목 `placeName`.
선택한 참여자끼리 균등 분담하고, 나머지 원은 사용자 ID 오름차순으로 배분합니다. 완료 상태에서 지출을 변경하면 진행 중으로 돌아갑니다. 실제 송금은 수행하지 않습니다.

배포 시 새 백엔드 빌드가 필요합니다. 현재 `ddl-auto=update` 설정은 새 테이블을 생성하며, 자동 변경을 끈 환경에서는 [settlement.sql](../database/settlement.sql)을 적용하세요. 실행 중인 운영 서버나 DB에는 자동 배포·변경하지 않았습니다.

검증: `./gradlew test --tests 'com.tripmate.backend.settlement.*'` (DB 접속 없이 계산·서비스 단위 테스트).

AI 요약 일정 추가: `POST /api/trips/{tripId}/schedules/import` (인증 및 기존 일정 생성과 같은 요청 본문).
같은 여행의 날짜·시간·제목·장소가 일치하면 기존 일정을 반환합니다. 제목·장소의 공백은 비교에서 제외합니다.
응답은 `{created, schedule}`이며 새로 저장하면 201 / `created: true`, 이미 존재하면 200 / `false`입니다.
여행 행 잠금과 READ_COMMITTED 트랜잭션으로 동시 추가를 직렬화합니다. 기존 일정 생성 API도 같은 잠금을 사용합니다.
DB 스키마 변경은 없으며, 새 프론트를 사용하기 전에 백엔드를 배포해야 합니다. 기존 중복 데이터는 자동 삭제하지 않습니다.
