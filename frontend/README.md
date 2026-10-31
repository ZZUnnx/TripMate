# TripMate Frontend

Flutter 앱입니다. 주요 파일만 표시했으며, 세부 위젯은 기능별 폴더에 모여 있습니다.

```text
frontend/
├─ lib/
│  ├─ main.dart                         # 앱 실행·Provider 등록·테마·라우트
│  ├─ controllers/                      # 기능별 데이터·상태 관리
│  │  ├─ chat/
│  │  │  ├─ ai_summary_controller.dart   # AI 일정·예약 검증·공유 일정 저장
│  │  │  ├─ chat_detail_controller.dart  # 채팅방 데이터·소켓·전송 상태
│  │  │  ├─ chat_list_controller.dart    # 채팅 목록 조회·갱신
│  │  │  └─ create_chat_room_controller.dart # 채팅방 생성·저장 상태
│  │  ├─ calendar/
│  │  │  ├─ calendar_controller.dart     # 일정 조회·추가·갱신
│  │  │  └─ trip_calendar_detail_controller.dart # 타임라인·참여자 조회
│  │  └─ settlement/
│  │     ├─ settlement_list_controller.dart # 참여 여행 정산 목록
│  │     └─ settlement_detail_controller.dart # 지출 CRUD·정산 완료·갱신
│  ├─ models/
│  │  ├─ chat_room.dart                 # 채팅방 데이터
│  │  ├─ chat_message.dart              # 메시지 데이터
│  │  ├─ trip.dart                      # 여행 데이터
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
├─ test/                               # 위젯 테스트
└─ pubspec.yaml                        # 패키지·이미지 리소스 설정
```

UI는 `widgets`, 화면 흐름은 `screens`, 분리된 기능 상태는 `controllers`, API 호출은 `services`에서 수정합니다. 홈의 여행·통계는 예시 데이터이며, 정산은 실제 API 데이터를 사용합니다.

AI 요약의 ‘공유 일정에 추가’는 날짜·제목이 확인된 일정과 예약을 해당 여행에 저장합니다. 예약은 시작일에 표시하고 종료일은 메모에 보관하며, 정산 정보는 제외합니다. 캘린더 탭에 진입하면 최신 일정을 조회합니다.

일정 삭제는 통합 캘린더의 날짜별 목록과 여행 상세 타임라인에서 카드를 왼쪽으로 밀면 나타나는 휴지통 버튼으로 진행합니다. 확인창에서 승인하면 서버에서 삭제하고 화면을 갱신합니다.

정산은 참여 여행 선택 → 지출 등록·수정·삭제 → 송금 계획 확인 → 완료 표시 흐름입니다. 결제자와 균등 분담 대상을 선택할 수 있으며, 지출을 바꾸면 완료 상태가 해제됩니다. 상단 복사 버튼은 지출 내역을 CSV로 복사합니다. 실제 송금은 수행하지 않습니다. 새 정산 API를 사용하려면 백엔드 재배포가 필요합니다.
