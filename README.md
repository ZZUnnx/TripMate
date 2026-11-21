# TripMate

AI 기반 협업 여행 일정 관리 프로젝트입니다. Flutter 앱에서 여행방·채팅·공유 일정·정산을 관리하며, Spring Boot 서버가 MySQL과 Gemini API에 연결됩니다.

문서 기준일: **2026-11-11**. 현재 작업 디렉터리의 소스를 기준으로 작성했습니다. 코드 구현 상태와 운영 서버의 배포·통합 검증 여부는 구분합니다.

## 프로젝트 구성

| 위치 | 역할 |
| --- | --- |
| [frontend/](frontend/README.md) | Flutter 앱, 화면·상태·API 통신 |
| [backend/](backend/README.md) | Java 21 / Spring Boot 4.1.1 서버 |
| [database/](database/README.md) | DB 관련 SQL과 적용 범위 |
| [docs/requirements/](docs/requirements/requirements.md) | 요구사항·기능별 구현 상태·확인된 제한 |
| [docs/api/](docs/api/api-spec.md) | 실제 구현 API와 아직 없는 API 구분 |
| [docs/architecture/](docs/architecture/README.md) | 화면→API→서버→DB 연결 및 실행 구성 |
| [docs/database/](docs/database/README.md) | JPA 엔티티 기준 데이터 구조 |
| [docs/ui/](docs/ui/README.md) | 화면별 동작·미연결 버튼·고정값 |

## 현재 기능

- 회원가입·로그인, 여행방 생성·목록, 가입된 사용자 이메일로 멤버 추가
- REST 메시지 이력 조회와 WebSocket/STOMP 텍스트 채팅
- 공유 일정 조회·추가·삭제, 여행별 타임라인
- Gemini 채팅 분석, 사용자가 선택한 일정·예약 및 확인한 지출 저장
- 지출 등록·수정·삭제, 균등 분담·송금 계획 계산, 정산 완료 표시
- 실제 API를 사용하는 홈 여행·일정·정산 집계

일정 수정은 서버 API만 연결되어 있고 앱 수정 화면은 없습니다. 지도·검색·파일 등 일부 UI는 준비 중이며, 캘린더 상세 비용과 채팅방 서랍 수치에는 고정값이 남아 있습니다. 자세한 판정과 근거는 [기능 현황](docs/requirements/requirements.md)을 참고하세요. 실제 송금은 수행하지 않습니다.

## 실행

프론트엔드: Flutter 설치 후 다음 명령을 실행합니다. 점검 환경은 Flutter 3.47.3 / Dart 3.13.3입니다.

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

백엔드: Java 21, MySQL, 환경변수 설정이 필요합니다. 필요한 값은 [백엔드 실행 안내](backend/README.md)에 있습니다.

```powershell
cd backend
.\gradlew.bat bootRun
```

Linux/macOS에서는 `./gradlew bootRun`을 사용합니다. 앱의 일반 API 주소는 `https://api.dwsdd.com`, AI 분석 주소는 `http://100.79.181.89:8080`으로 각각 고정되어 있습니다. 로컬 서버 실행만으로 앱 연결 대상이 바뀌지는 않습니다.

## 최근 검증

2026-11-11 점검 결과:

- 프론트 전체 정적 분석: 문제 없음
- 프론트 전체 테스트: 58개 통과
- DB 연결 없는 백엔드 일정·정산 단위 테스트: 13개 통과
- 설정된 서버의 인증 없는 여행·정산 목록 GET 요청: 각각 HTTP 401

실제 로그인 후 DB 저장·조회, 여러 기기 간 채팅, Gemini 응답, 최신 코드의 운영 배포 여부는 이번 점검에서 확인하지 않았습니다. 테스트 통과가 전체 통합 동작을 보장하지는 않습니다.
