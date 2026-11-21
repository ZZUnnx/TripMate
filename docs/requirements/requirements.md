# 요구사항과 구현 현황

기준일: **2026-11-11**. 현재 작업 디렉터리의 실제 코드와 실행한 검증을 기준으로 정리합니다. 원래 요구사항은 유지하고, 다른 방식으로 구현된 부분과 아직 없는 부분을 구분합니다.

## 원래 핵심 요구사항

1. 회원가입·로그인: 입력 검증, 로그인 후 1시간 유지
2. 여행방 생성
3. 여행 멤버 초대
4. 실시간 채팅
5. 일정 등록 및 관리
6. AI 채팅 분석
7. AI 일정 후보 생성
8. 사용자 승인 후 일정 확정
9. 장소 및 지도 링크 관리

이후 추가된 코드 범위에는 실제 데이터 기반 홈과 지출·정산 관리가 있습니다. 아래 미구현 판정은 위 요구사항, 기존 API 명세, 현재 화면에 노출된 기능을 기준으로 하며 다른 기능을 임의로 필수 요구사항으로 추가하지 않습니다.

## 판정 기준

- **구현 완료**: 필요한 코드·화면·API 연결 존재. 운영 환경 검증 완료라는 뜻은 아님.
- **일부 구현**: 일부 계층만 있거나 고정값·미연결 단계·요구사항 차이가 존재.
- **미구현**: 문서상 예정 또는 화면에 노출되어 있으나 실제 처리 없음.
- **확인 불가**: 현재 코드·실행 결과만으로 운영 동작을 확정할 수 없음.

## 기능별 상태

아래 백엔드 소스 루트는 `backend/src/main/java/com/tripmate/backend/`입니다.

| 기능 | 상태 | 현재 동작·제한 | 근거 |
| --- | --- | --- | --- |
| 회원가입·로그인·로컬 로그아웃 | 구현 완료 | 입력 검증, BCrypt, JWT, 로컬 로그인 정보 저장·삭제 | [앱 인증](../../frontend/lib/services/auth_service.dart), [서버 인증](../../backend/src/main/java/com/tripmate/backend/auth/AuthService.java) |
| 1시간 로그인 유지 | 일부 구현 | 서버 기본 만료 24시간. 앱은 토큰 존재 여부로 로그인 상태를 판단하며 만료 자동 해제·갱신 흐름 없음 | [설정](../../backend/src/main/resources/application.properties), [AuthProvider](../../frontend/lib/providers/auth_provider.dart) |
| 여행방 생성·목록 | 구현 완료 | 앱은 제목만 입력. 서버는 여행지·기간도 선택 입력 지원 | [생성 Controller](../../frontend/lib/controllers/chat/create_chat_room_controller.dart), [TripController](../../backend/src/main/java/com/tripmate/backend/trip/TripController.java) |
| 멤버 초대·조회 | 구현 완료 | 가입된 사용자 이메일로 즉시 추가. 이메일 발송·수락 대기 방식 아님 | [TripMemberService](../../backend/src/main/java/com/tripmate/backend/trip/TripMemberService.java) |
| 텍스트 채팅·이력 | 구현 완료 | REST 이력, STOMP 송수신, JWT·여행 접근 검사 | [소켓](../../frontend/lib/services/chat_socket_service.dart), [서버 채팅](../../backend/src/main/java/com/tripmate/backend/chat/ChatStompController.java) |
| 홈 대시보드 | 구현 완료 | 실제 여행·일정·정산 API 조합. 동행 인원은 본인을 제외한 중복 없는 참여자 | [HomeController](../../frontend/lib/controllers/home/home_controller.dart), [HomeData](../../frontend/lib/models/home_data.dart) |
| 공유 일정 조회·추가·삭제 | 구현 완료 | 캘린더·여행 타임라인, 수동 추가, 스와이프 삭제 | [CalendarScreen](../../frontend/lib/screens/calendar/calendar_screen.dart), [일정 API](../../backend/src/main/java/com/tripmate/backend/schedule/ScheduleController.java) |
| 일정 수정·상세에서 추가 | 일부 구현 | 수정 API·앱 서비스 있음. 수정 화면 없음. 상세 추가 버튼은 준비 중 | [상세 화면](../../frontend/lib/screens/calendar/trip_calendar_detail_screen.dart), [앱 서비스](../../frontend/lib/services/schedule_service.dart) |
| 개인 일정 | 미구현 | 범례만 있으며 개인 일정 전용 모델·API·저장 흐름 없음 | [범례](../../frontend/lib/widgets/calendar/calendar_legend.dart) |
| AI 채팅 분석 | 일부 구현 | Gemini 호출·JSON 결과 처리, JWT·여행 접근 검사, 일반 API와 HTTPS 주소 공유. 운영 통합 검증 미완료 | [앱 AI](../../frontend/lib/services/ai_service.dart), [서버 AI](../../backend/src/main/java/com/tripmate/backend/ai/AiChatAnalysisController.java) |
| AI 결과 확인 후 일정·지출 저장 | 구현 완료 | 일정 선택·중복 확인 import, 지출 확인·저장·재시도. 예약 종료일은 메모 | [AiSummaryController](../../frontend/lib/controllers/chat/ai_summary_controller.dart) |
| 영구 후보 보관·승인 이력 | 일부 구현 | 후보 Entity만 있음. 후보 조회·승인 API·Repository 없음. 현재 결과에서 확정 일정으로 직접 저장 | [ScheduleCandidate](../../backend/src/main/java/com/tripmate/backend/schedule/ScheduleCandidate.java), [API 현황](../api/api-spec.md) |
| 지출·정산 | 구현 완료 | 지출 CRUD, 균등 분담·송금 계획, 완료 표시, CSV 클립보드 복사 | [정산 화면](../../frontend/lib/screens/settlement/settlement_screen.dart), [정산 Service](../../backend/src/main/java/com/tripmate/backend/settlement/SettlementService.java) |
| 캘린더 상세 비용 | 일부 구현 | 정산 API와 별개로 총액 0·인원 null 고정 전달 | [상세 화면](../../frontend/lib/screens/calendar/trip_calendar_detail_screen.dart) |
| 장소·URL·지도 | 일부 구현 | 장소·URL 저장과 링크 복사 가능. 지도 화면·지도 API 연결 없음 | [타임라인](../../frontend/lib/widgets/calendar/detail/trip_timeline.dart), [지도 안내](../../frontend/lib/widgets/calendar/detail/trip_map_notice.dart) |
| 검색·알림 설정·채팅방 나가기 | 미구현 | 표시용 검색창 또는 빈 콜백 | [검색창](../../frontend/lib/widgets/chat/chat_search_bar.dart), [서랍](../../frontend/lib/widgets/chat/detail/chat_room_side_menu.dart), [홈 헤더](../../frontend/lib/widgets/home/home_top_header.dart) |
| 사진·파일·위치 공유·투표·연락처 | 미구현 | 메뉴만 있고 준비 중 안내. 별도 처리 흐름 없음 | [채팅 상세](../../frontend/lib/screens/chat/chat_detail_screen.dart), [첨부 메뉴](../../frontend/lib/widgets/chat/detail/chat_attachment_menu.dart) |
| AI 재분석·상단 편집/삭제 아이콘 | 미구현 | 빈 콜백. 일정 선택과 지출 확인 기능은 별도로 동작 | [AI 요약 UI](../../frontend/lib/widgets/chat/detail/ai_summary_sheet.dart) |
| 채팅 읽음·고정·서랍 수치 | 일부 구현 | unread=0, pinned=false. 서랍 일정·앨범·파일·링크 건수 고정 | [채팅 Service](../../backend/src/main/java/com/tripmate/backend/chat/ChatRoomService.java), [서랍](../../frontend/lib/widgets/chat/detail/chat_room_side_menu.dart) |
| 실제 DB·AI·최신 배포 | 확인 불가 | 인증 없는 서버 응답 이외의 운영 통합 실행 미확인 | 아래 검증 기록 |

실제 금융 송금은 현재 정산 기능의 제공 범위가 아닙니다. 송금 계획 계산과 완료 표시를 수행합니다.

## 확인된 제한·불일치

- 로그인 화면은 요청 완료 시 `finally`에서 로딩을 해제해 실패 후 재시도할 수 있습니다. 화면이 해제된 경우에는 상태를 갱신하지 않습니다. 실패 시나리오 실기기 재현은 하지 않았습니다.
- 일반 API와 AI 분석은 같은 HTTPS 주소를 사용합니다. 운영 배포 버전과 실제 DB는 확인하지 않았습니다.
- AI 분석은 JWT·여행 접근 검사 후 전체 채팅을 외부 API로 전달합니다.
- 일정·지출 저장은 개별 요청입니다. 일부만 성공할 수 있으며 앱은 남은 항목 재시도를 지원합니다. 지출의 서버 동시 중복 방지는 구현되어 있지 않습니다.
- 홈 ‘확인 필요’는 지출이 있고 완료되지 않은 정산 목록입니다. 푸시 알림이나 변경 알림 이력을 뜻하지 않습니다.

## 2026-11-11 검증 기록

| 실행 | 결과 | 범위 |
| --- | --- | --- |
| 프론트 `dart analyze` | 문제 없음 | 전체 프론트 정적 분석 |
| 프론트 `flutter test --no-pub` | 58개 통과 | 컨트롤러·위젯, 주입한 테스트 데이터 사용 |
| 백엔드 일정 import·정산 단위 테스트 | 13개 통과 | DB 연결 없는 계산·Service 테스트 |
| 운영 주소 여행·정산 목록 GET, 인증 없음 | 각각 401 | `https://api.dwsdd.com/api/trips`, `/api/settlements` |

백엔드는 `gradlew --offline test --tests 'com.tripmate.backend.settlement.*' --tests 'com.tripmate.backend.schedule.ScheduleImportTest'` 범위를 실행했습니다. 전체 Spring Context 테스트, 앱 실기기 실행, 인증 후 DB 저장·조회, 다중 사용자 실시간 채팅, Gemini 응답, 운영 스키마·배포 버전은 확인하지 않았습니다.

테스트의 모의 데이터는 실제 앱의 더미 데이터와 다릅니다. 테스트 통과를 운영 통합 검증 완료로 해석하지 않습니다.
