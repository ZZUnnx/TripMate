# TripMate Frontend

Flutter 앱입니다. 주요 파일만 표시했으며, 세부 위젯은 기능별 폴더에 모여 있습니다.

```text
frontend/
├─ lib/
│  ├─ main.dart                         # 앱 실행·Provider 등록·테마·라우트
│  ├─ controllers/                      # 기능별 데이터·상태 관리
│  │  ├─ chat/
│  │  │  ├─ chat_detail_controller.dart  # 채팅방 데이터·소켓·전송 상태
│  │  │  ├─ chat_list_controller.dart    # 채팅 목록 조회·갱신
│  │  │  └─ create_chat_room_controller.dart # 채팅방 생성·저장 상태
│  │  └─ calendar/
│  │     ├─ calendar_controller.dart     # 일정 조회·추가·갱신
│  │     └─ trip_calendar_detail_controller.dart # 타임라인·참여자 조회
│  ├─ models/
│  │  ├─ chat_room.dart                 # 채팅방 데이터
│  │  ├─ chat_message.dart              # 메시지 데이터
│  │  ├─ trip.dart                      # 여행 데이터
│  │  ├─ trip_member.dart               # 여행 참여자 데이터
│  │  └─ trip_schedule.dart             # 일정 데이터
│  ├─ providers/
│  │  └─ auth_provider.dart             # 로그인 정보 저장·로드·로그아웃
│  ├─ services/
│  │  ├─ auth_service.dart              # 인증 API
│  │  ├─ chat_service.dart              # 채팅방·메시지·참여자 API
│  │  ├─ chat_socket_service.dart       # 실시간 메시지 송수신
│  │  ├─ schedule_service.dart          # 여행·일정 API
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
│  │  └─ settlement/settlement_screen.dart  # 정산 탭·결과 창 연결
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
│        ├─ settlement_result_sheet.dart # 최종 정산 결과 창
│        └─ presentation/settlement_sample_data.dart # 정산 예시 데이터
├─ assets/images/                      # 화면 이미지
├─ test/                               # 위젯 테스트
└─ pubspec.yaml                        # 패키지·이미지 리소스 설정
```

UI는 `widgets`, 화면 흐름은 `screens`, 분리된 기능 상태는 `controllers`, API 호출은 `services`에서 수정합니다. 홈의 여행·통계와 정산 금액은 현재 예시 데이터입니다.
