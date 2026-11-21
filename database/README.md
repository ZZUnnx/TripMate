# TripMate Database

문서 기준일: **2026-11-11**. 현재 서버는 MySQL과 Spring Data JPA를 사용합니다. 실제 운영 DB에 접속해 스키마를 확인한 문서는 아닙니다.

## 파일 상태

| 파일 | 현재 내용 | 용도·제한 |
| --- | --- | --- |
| [schema.sql](schema.sql) | 예상 테이블 이름을 적은 주석 | 전체 DB 생성 스크립트가 아님 |
| [seed.sql](seed.sql) | 초기 데이터 작성 안내 주석 | 실행 가능한 초기 데이터 없음 |
| [settlement.sql](settlement.sql) | 정산 관련 CREATE TABLE IF NOT EXISTS | 정산 테이블 추가용. `users`, `trips`가 먼저 있어야 함 |

전체 엔티티·관계·API 필드 매핑은 [DB 구조 문서](../docs/database/README.md)를 참고하세요. 현재 테이블 매핑의 기준은 `backend/src/main/java/com/tripmate/backend/`의 JPA Entity입니다.

## 설정과 스키마 생성

서버의 `application.properties`에서 `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`를 읽습니다. 현재 `spring.jpa.hibernate.ddl-auto=update` 설정이므로 서버 기동 시 JPA가 연결된 DB의 스키마 갱신을 시도합니다.

이 설정과 `settlement.sql`은 버전별 마이그레이션 도구를 대체하지 않습니다. 저장소에는 전체 DB를 처음부터 만드는 완성된 SQL이나 Flyway/Liquibase 기반 마이그레이션 구성이 없습니다.

자동 스키마 변경을 끈 환경에서 정산 기능을 추가할 때는 대상 DB의 기존 구조를 확인한 후 `settlement.sql` 적용 여부를 결정합니다. 이 파일은 기존 `users`, `trips`를 만들거나 기존 테이블의 구조 차이를 수정하지 않습니다. `IF NOT EXISTS`도 기존 테이블의 누락 컬럼을 보완하지 않습니다.

## 확인 범위

- 소유자·여행 참여자, 일정·채팅·지출 관계는 소스의 JPA 매핑 기준입니다.
- 정산 SQL에는 결제자·분담 대상 사용자 외래 키가 있으며, JPA의 숫자 ID 필드 매핑과 제약이 완전히 동일하다고 가정하면 안 됩니다.
- 실제 DB의 컬럼·인덱스·외래 키·기존 데이터 상태는 확인하지 않았습니다.
- 문서 갱신 과정에서 DB 생성·수정·데이터 입력은 수행하지 않았습니다.
