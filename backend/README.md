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
