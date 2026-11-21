# TripMate Frontend

문서 기준일: **2026-11-11**. Flutter 앱입니다. 현재 소스의 연결 상태를 설명하며 운영 배포·실기기 검증 완료를 뜻하지 않습니다.

## 실행과 사용 기술

- 점검 SDK: Flutter 3.47.3 / Dart 3.13.3 (`pubspec.yaml`: Dart ^3.13.3)
- Provider·ChangeNotifier 상태 관리, HTTP JSON, SharedPreferences 로그인 정보, STOMP 실시간 채팅
- 의존성·이미지: [pubspec.yaml](pubspec.yaml)

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

점검 환경에서 Windows·Chrome·Edge가 실행 대상으로 인식되었습니다. 실제 앱 실행·Android/iOS 배포 검증은 이번에 수행하지 않았습니다.

일반 API와 [AI 분석](lib/services/ai_service.dart)은 [AuthService](lib/services/auth_service.dart)의 `https://api.dwsdd.com`을 함께 사용하며 AI 요청에도 Bearer JWT를 전달합니다. STOMP 주소는 일반 API에서 `wss://api.dwsdd.com/ws/chat`로 만듭니다. 주소가 코드에 고정되어 있어 로컬 백엔드 실행만으로 전환되지 않으며 운영 배포 버전과 실제 DB는 미확인입니다.

## 파일 구조

주요 파일만 표시했으며, 세부 위젯은 기능별 폴더에 모여 있습니다.

```text
frontend/
├─ lib/
│  ├─ main.dart                         # 앱 실행·Provider 등록·테마·라우트
│  ├─ controllers/                      # 기능별 데이터·상태 관리
│  │  ├─ chat/
│  │  │  ├─ ai_summary_controller.dart   # AI 일정·예약 검증·일정 및 정산 저장
│  │  │  ├─ chat_detail_controller.dart  # 채팅방 데이터·소켓·전송 상태
│  │  │  ├─ chat_list_controller.dart    # 채팅 목록 조회·갱신
│  │  │  └─ create_chat_room_controller.dart # 채팅방 생성·저장 상태
│  │  ├─ calendar/
│  │  │  ├─ calendar_controller.dart     # 일정 조회·추가·갱신
│  │  │  └─ trip_calendar_detail_controller.dart # 타임라인·참여자 조회
│  │  ├─ home/home_controller.dart      # 홈 여행·일정·정산 조회·새로고침
│  │  └─ settlement/
│  │     ├─ settlement_list_controller.dart # 참여 여행 정산 목록
│  │     └─ settlement_detail_controller.dart # 지출 CRUD·정산 완료·갱신
│  ├─ models/
│  │  ├─ chat_room.dart                 # 채팅방 데이터
│  │  ├─ chat_message.dart              # 메시지 데이터
│  │  ├─ trip.dart                      # 여행 데이터
│  │  ├─ home_data.dart                 # 홈 집계·여행/일정 날짜 필터
│  │  ├─ trip_member.dart               # 여행 참여자 데이터
│  │  ├─ settlement.dart                # 지출·집계·송금 계획 데이터
│  │  └─ trip_schedule.dart             # 일정 데이터
│  ├─ providers/
│  │  └─ auth_provider.dart             # 로그인 정보 저장·로드·로그아웃
│  ├─ services/
│  │  ├─ auth_service.dart              # 인증 API
│  │  ├─ chat_service.dart              # 채팅방·메시지·참여자 API
│  │  ├─ chat_socket_service.dart       # 실시간 메시지 송수신
│  │  ├─ schedule_service.dart          # 여행·일정 API
│  │  ├─ settlement_service.dart        # 지출·정산 API
│  │  └─ ai_service.dart                # AI 채팅 분석 API
│  ├─ screens/                         # 화면 배치·상태·기능 연결
│  │  ├─ app_shell.dart                 # 홈·채팅·캘린더·정산 탭 전환
│  │  ├─ auth/
│  │  │  ├─ login_screen.dart           # 로그인
│  │  │  └─ signup_screen.dart          # 회원가입
│  │  ├─ home/home_screen.dart          # 홈 영역 조립
│  │  ├─ chat/
│  │  │  ├─ chat_screen.dart            # 채팅 목록·방 생성
│  │  │  └─ chat_detail_screen.dart     # 채팅방 UI·스크롤·화면 이동
│  │  ├─ calendar/
│  │  │  ├─ calendar_screen.dart        # 통합 캘린더·일정 추가
│  │  │  └─ trip_calendar_detail_screen.dart # 여행 전체 일정
│  │  └─ settlement/
│  │     ├─ settlement_list_screen.dart   # 참여 여행 목록·정산 상태
│  │     └─ settlement_screen.dart       # 선택한 여행의 정산 상세
│  └─ widgets/                         # 영역별 UI와 전용 하위 위젯
│     ├─ common/
│     │  ├─ bottom_navigation.dart      # 공통 하단 메뉴
│     │  └─ responsive.dart             # 화면 크기에 따른 크기 조정
│     ├─ home/                         # 헤더·프로필·여행·일정 요약
│     ├─ chat/                         # 목록·검색창·채팅방 생성 창
│     │  └─ detail/                    # 말풍선·입력창·사이드 메뉴
│     │     ├─ ai_summary_sheet.dart    # AI 요약 창
│     │     └─ invite_member_sheet.dart # 친구 초대 창
│     ├─ calendar/                     # 달력·날짜 선택·일정 목록
│     │  ├─ add_schedule_sheet.dart     # 일정 입력 창
│     │  ├─ detail/                    # 여행 요약·비용·타임라인
│     │  └─ presentation/
│     │     ├─ calendar_data.dart       # 조회 데이터 묶음
│     │     ├─ calendar_view_data.dart  # 표시용 데이터·스타일
│     │     ├─ calendar_transformations.dart # 일정 변환·계산·정렬
│     │     └─ calendar_formatters.dart # 날짜·금액·문구 표시 형식
│     └─ settlement/                   # 지출 요약·탭·결제자·장소별 내역
│        ├─ settlement_trip_card.dart   # 여행별 정산 목록 카드
│        ├─ settlement_result_sheet.dart # 최종 정산 결과 창
│        ├─ expense_editor_sheet.dart   # 지출 등록·수정 입력창
│        └─ presentation/settlement_view_data.dart # 실제 정산 데이터 표시 변환
├─ assets/images/                      # 화면 이미지
├─ test/                               # 컨트롤러·위젯 테스트
└─ pubspec.yaml                        # 패키지·이미지 리소스 설정
```

## 화면과 저장 흐름

UI는 `widgets`, 화면 흐름은 `screens`, 분리된 기능 상태는 `controllers`, API 호출은 `services`에서 수정합니다. 홈과 정산은 실제 API 데이터를 사용합니다.

홈은 로그인한 사용자의 참여 여행, 여행별 일정, 정산 목록을 조회합니다. 프로필의 참여 여행 수와 동행 인원(본인을 제외한 중복 없는 참여자), 가장 가까운 진행 중/예정 여행, 다음 일정, 전체 여행 지출 합계, 미완료 정산, 이번 달 일정을 표시합니다. ‘확인 필요’는 지출이 등록되어 있고 완료 표시가 되지 않은 정산이며, 별도 알림 데이터는 생성하지 않습니다. 여행 기간이 없으면 ‘날짜 미정’으로 표시합니다. 홈 탭 재진입, 상세 화면 복귀, 아래로 당기기로 새로고침하며, 일부 조회 실패는 해당 영역에 오류로 표시하고 나머지 데이터는 유지합니다.

AI 요약에서는 날짜·제목이 확인된 일정과 예약을 해당 여행에 저장합니다. 예약은 시작일에 표시하고 종료일은 메모에 보관합니다. 정산 항목과 금액이 있는 예약은 ‘확인’에서 금액·결제자·분담 대상·지출일을 검토하고 ‘요약에 반영’을 누르면 저장 대상에 포함됩니다. 결제자는 본인, 분담 대상은 여행 참여자 전원, 날짜가 없으면 오늘을 기본값으로 제시하며 직접 변경할 수 있습니다. ‘선택한 일정·정산 저장’을 누르면 일정과 확인한 지출을 각각 일정 API와 정산 API에 저장합니다. 동일한 제목·금액·결제자·날짜·장소·분담 대상의 기존 지출은 제외하며, 일부 저장 실패 시 남은 항목만 재시도합니다. 캘린더와 정산 탭에 진입하면 최신 데이터를 조회합니다.

일정 삭제는 통합 캘린더의 날짜별 목록과 여행 상세 타임라인에서 카드를 왼쪽으로 밀면 나타나는 휴지통 버튼으로 진행합니다. 확인창에서 승인하면 서버에서 삭제하고 화면을 갱신합니다.

정산은 참여 여행 선택 → 지출 등록·수정·삭제 → 송금 계획 확인 → 완료 표시 흐름입니다. 결제자와 균등 분담 대상을 선택할 수 있으며, 지출을 바꾸면 완료 상태가 해제됩니다. 상단 복사 버튼은 지출 내역을 CSV로 복사합니다. 실제 송금은 수행하지 않습니다. 실행 서버가 현재 정산 API를 제공하는 버전인지 별도 확인해야 합니다.
## 미연결 UI와 고정값

- 일정 수정 API·서비스는 있으나 수정 입력 화면은 없고 여행 상세의 추가 버튼은 준비 중입니다.
- 개인 일정은 범례만 있고, 캘린더 상세 비용은 0원 고정입니다. 지도는 준비 중이며 저장 URL 복사만 연결됩니다.
- 홈 검색·알림, 채팅 검색·이모지·알림 설정·나가기, 사진·파일·위치 공유·투표·연락처 등은 미연결입니다.
- 채팅방 서랍의 공지·일정·앨범·파일·링크 건수, 정산 상태·알림 상태에는 고정값이 있습니다. ‘공지’는 AI 요약을 엽니다.
- AI 요약의 상단 편집·삭제 아이콘과 재분석은 미연결입니다. 지출 행 확인·수정·제외와 일정 선택·저장은 연결되어 있습니다.
- 로그인 실패 후 로딩 해제 코드가 없으며 토큰 만료 자동 해제·갱신 흐름도 없습니다. 서버 기본 JWT 만료 24시간은 원래 1시간 요구사항과 다릅니다.

전체 상태와 근거는 [기능 현황](../docs/requirements/requirements.md), 화면별 차이는 [UI 문서](../docs/ui/README.md)를 참고하세요.

## 검증

```powershell
cd frontend
flutter analyze
flutter test --no-pub
```

2026-11-11 전체 정적 분석 문제 없음, 테스트 58개 통과. 의존성 설치가 안 된 환경에서는 먼저 `flutter pub get`이 필요합니다. 테스트의 주입 데이터는 운영 API·DB 검증이 아니며 실제 앱의 더미 데이터와 구분합니다. [API 명세](../docs/api/api-spec.md)에 연결 주소·요청 형식·인증 범위가 있습니다.
