# TripMate 화면과 실제 연결 상태

기준일: **2026-11-11**. Flutter 소스 기준이며 실기기 UI를 실행해 확인한 문서는 아닙니다. 표시되는 화면과 실제 처리 기능을 구분합니다.

## 공통 구조

- 진입점: [main.dart](../../frontend/lib/main.dart)
- 탭: [AppShell](../../frontend/lib/screens/app_shell.dart)의 홈(0), 채팅(1), 캘린더(2), 정산(3)
- 공용 하단 메뉴: [widgets/common/bottom_navigation.dart](../../frontend/lib/widgets/common/bottom_navigation.dart)
- `ResponsiveScope`, `context.rs()` 기준 폭 430. 주요 배경 `#F7FAF9`, 브랜드 `#148776`.
- 세부 파일 구조: [프론트 README](../../frontend/README.md)

## 홈

[HomeScreen](../../frontend/lib/screens/home/home_screen.dart), [HomeController](../../frontend/lib/controllers/home/home_controller.dart), [HomeData](../../frontend/lib/models/home_data.dart).

실제 여행·일정·정산 API로 다음을 표시합니다.

- 로그인 닉네임, 참여 여행 수, 본인을 제외한 중복 없는 동행 인원
- 종료되지 않은 여행 중 시작일이 빠른 여행. 시작일 미정 여행은 뒤에 배치
- 가장 가까운 여행의 일정·예약·참여 인원과 참여자 이니셜
- 지출이 있고 완료되지 않은 여행 정산을 ‘확인 필요’에 표시
- 다음 일정, 모든 참여 여행 지출 합계·건수, 예정 여행 최대 5개
- 현재 연도·월에 속하는 일정

별도 알림 데이터나 가짜 변경 내역을 생성하지 않습니다. 홈 탭 재진입·일정/정산 상세 복귀·아래로 당기기 시 갱신합니다. 빈 데이터와 조회 실패를 구분하며 일부 영역 실패 시 나머지는 유지합니다. 여행·일정 카드는 일정 상세로, 확인 필요 정산은 정산 상세로 이동합니다. 일정이 없는 여행은 캘린더 탭으로 이동합니다. ‘전체 보기’는 여행방이 있는 채팅 탭으로 이동합니다.

헤더의 검색·알림 아이콘은 빈 동작입니다. 프로필의 설정 모양 버튼은 현재 설정 화면이 아니라 로그아웃을 수행합니다. 로그인하지 않은 경우 로그인 진입을 제공합니다.

## 인증

[로그인](../../frontend/lib/screens/auth/login_screen.dart), [회원가입](../../frontend/lib/screens/auth/signup_screen.dart), [AuthProvider](../../frontend/lib/providers/auth_provider.dart).

회원가입·로그인 API 및 로컬 저장소 연결이 있습니다. 로그인 실패 후 로딩 상태를 해제하는 코드가 없어 재시도 비활성화 가능성이 있습니다. 앱은 JWT 만료 대신 저장된 토큰 존재 여부로 로그인 여부를 판단합니다. 1시간 유지 요구사항과 현재 24시간 서버 설정이 다릅니다.

## 채팅 목록·상세

[목록](../../frontend/lib/screens/chat/chat_screen.dart), [상세](../../frontend/lib/screens/chat/chat_detail_screen.dart), [서랍 메뉴](../../frontend/lib/widgets/chat/detail/chat_room_side_menu.dart).

- 여행방 목록·최근 메시지·참여 인원은 REST 데이터입니다. 생성 화면은 제목만 입력받습니다.
- 메시지 이력은 REST, 새 텍스트 메시지는 STOMP로 처리합니다. 로딩·빈 상태·실패 재조회가 있습니다.
- 서랍의 참여자 조회·이메일 멤버 추가, 공유 일정·정산 상세 이동은 연결되어 있습니다.
- ‘공지’는 현재 공지 목록이 아니라 AI 요약을 엽니다.
- 목록 검색 바는 입력 없는 표시용 텍스트이고 채팅방 검색 아이콘·이모지 버튼도 미연결입니다.
- 첨부 메뉴의 사진·카메라·파일·위치·일정·정산·투표·연락처 동작은 준비 중 안내입니다. 서랍의 공유 일정·정산 진입과는 다릅니다.
- 앨범·파일·링크는 준비 중이며 알림 설정·채팅방 나가기는 빈 콜백입니다.

서랍 고정값: 공지 1, 공유 일정 5개, 앨범 24장, 파일 3개, 링크 7개, 정산 ‘진행 중’, 알림 ‘켜짐’. 실제 조회 결과로 계산하지 않습니다. 서버 목록의 unread=0·pinned=false도 고정이며 AI 요약 배지는 마지막 메시지 유무에 따른 값입니다.

## AI 요약

[요약 Sheet](../../frontend/lib/widgets/chat/detail/ai_summary_sheet.dart), [저장 Controller](../../frontend/lib/controllers/chat/ai_summary_controller.dart).

- 분석 API 결과를 일정·예약·정산으로 나누어 표시합니다.
- 날짜·제목이 있고 선택 입력한 시간이 유효한 일정·예약을 선택하고 기존·중복 의심 항목을 구분합니다.
- 예약은 시작일에 표시하고 종료일은 메모에 넣습니다.
- 정산·금액 있는 예약의 ‘확인’에서 기존 지출 입력창을 열어 제목·금액·결제자·분담 대상·날짜·장소를 검토합니다.
- 기본 제안은 본인 결제·여행 참여자 전원 분담·날짜가 없으면 오늘입니다. AI의 peopleCount만으로 실제 분담 대상을 임의 확정하지 않습니다.
- ‘요약에 반영’은 저장 대상 선택이며, 하단 저장 버튼이 일정 import와 지출 생성 API를 호출합니다. 일부 실패 시 남은 항목을 재시도합니다.
- 요약 섹션 상단 편집·삭제 아이콘과 재분석 버튼은 빈 동작입니다. 지출 행의 확인·수정·저장 대상 제외는 연결되어 있습니다.

## 캘린더·여행 상세

[통합 캘린더](../../frontend/lib/screens/calendar/calendar_screen.dart), [여행 상세](../../frontend/lib/screens/calendar/trip_calendar_detail_screen.dart).

- 실제 참여 여행의 일정을 합쳐 월간 캘린더·선택일 목록·여행 전체 타임라인을 표시합니다.
- 통합 캘린더 상단 버튼은 여행·제목·날짜·시간·카테고리·장소·URL·메모 입력 후 저장합니다.
- 목록·타임라인을 스와이프해 확인 후 삭제합니다. 카드 펼침에서 상세·메모·URL과 링크 복사가 가능합니다.
- 개인 일정은 범례만 있으며 전용 데이터 연결은 없습니다.
- 일정 수정 화면은 없고 상세 헤더의 추가 버튼은 준비 중입니다.
- 상세 비용 카드는 총액 0·인원 null 고정이며 정산 API와 연결되지 않았습니다.
- 지도는 준비 중 안내입니다. 외부 지도 실행·지도 API 연결은 없습니다.

## 정산

[여행 목록](../../frontend/lib/screens/settlement/settlement_list_screen.dart), [정산 상세](../../frontend/lib/screens/settlement/settlement_screen.dart), [결과 Sheet](../../frontend/lib/widgets/settlement/settlement_result_sheet.dart).

실제 정산 API를 사용합니다. 여행 선택 후 지출 등록·수정·삭제, 결제자와 분담 대상 선택, 한눈에·결제자별·장소별 보기, 내 보낼/받을 금액과 송금 계획 확인이 가능합니다. 결과창에서 명시적으로 완료 표시하며 지출 변경 시 해제됩니다.

상단 복사는 지출 CSV를 클립보드에 넣습니다. 파일 다운로드·실제 송금은 수행하지 않습니다. 캘린더 상세의 고정 0원 카드와 이 화면의 실제 정산 데이터는 별개입니다.

## 검증·기획 참고

2026-11-11 프론트 테스트 58개와 전체 정적 분석이 통과했습니다. 주로 모의 응답을 이용한 컨트롤러·위젯 검증이며 운영 통합·실기기 동작 검증과 다릅니다. [기능 현황](../requirements/requirements.md)을 참고하세요.

이전 UI 문서의 Figma 참고 노드: 채팅 목록 `3:4519`, 채팅방 `9:4296`·`9:4380`·`9:4468`, AI 요약 `9:4659`, 홈 `23:4`, 캘린더 `29:767`·`29:1004`, 정산 `3:5101`·`39:2`·`39:134`. 역사적 디자인 참고이며 이번에 Figma와 일치 여부를 확인하지 않았습니다. 현재 코드는 4개 탭 기준입니다.
