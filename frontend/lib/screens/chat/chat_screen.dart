import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/chat/chat_avatars.dart';
import '../../widgets/chat/chat_header.dart';
import '../../widgets/chat/chat_room_card.dart';
import '../../widgets/chat/chat_section_header.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    this.currentIndex = 1,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Builder(
                  builder: (context) {
                    return Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Stack(
                          children: [
                            ListView(
                              padding: context.insetsFromLTRB(22, 24, 22, 118),
                              children: const [
                                ChatHeader(),
                                ResponsiveGap(height: 30),
                                ChatSectionHeader(
                                  title: '고정된 채팅',
                                  showCollapseButton: true,
                                ),
                                ResponsiveGap(height: 12),
                                ChatRoomCard(
                                  title: '제주도 여행',
                                  message: '민수 : 렌터카 정산 올렸어!',
                                  time: '오전 10:24',
                                  badgeText: 'AI 요약 가능',
                                  unreadCount: 3,
                                  avatar: TravelAvatar(
                                    style: TravelAvatarStyle.jeju,
                                  ),
                                ),
                                ResponsiveGap(height: 10),
                                ChatRoomCard(
                                  title: '홋카이도 여행',
                                  message: '준영 : 일정표 수정했어!',
                                  time: '월',
                                  isPinned: true,
                                  avatar: TravelAvatar(
                                    style: TravelAvatarStyle.hokkaido,
                                  ),
                                ),
                                ResponsiveGap(height: 28),
                                ChatSectionHeader(title: '최근 채팅'),
                                ResponsiveGap(height: 12),
                                ChatRoomCard(
                                  title: '부산 당일치기',
                                  message: '서연 : 점심은 1시에 먹자 😊',
                                  time: '어제',
                                  avatar: TravelAvatar(
                                    style: TravelAvatarStyle.busan,
                                  ),
                                ),
                                ResponsiveGap(height: 1),
                                ChatRoomCard(
                                  title: '팀 프로젝트',
                                  message: '민수 : 발표 자료 올렸어!',
                                  time: '오전 9:10',
                                  unreadCount: 2,
                                  avatar: GroupAvatar(),
                                ),
                                ResponsiveGap(height: 1),
                                ChatRoomCard(
                                  title: '가족',
                                  message: '엄마 : 조심히 다녀와! 💙',
                                  time: '일',
                                  avatar: FamilyAvatar(),
                                ),
                                ResponsiveGap(height: 1),
                                ChatRoomCard(
                                  title: '유럽 여행 준비',
                                  message: '서연 : 항공권도 알아보자!',
                                  time: '9/11',
                                  avatar: PersonAvatar(),
                                ),
                                ResponsiveGap(height: 1),
                                ChatRoomCard(
                                  title: '다낭 여행',
                                  message: '준영 : 숙소 예약 완료했습니다!',
                                  time: '9/10',
                                  avatar: TravelAvatar(
                                    style: TravelAvatarStyle.danang,
                                  ),
                                ),
                                ResponsiveGap(height: 1),
                                ChatRoomCard(
                                  title: '동남아 배낭여행',
                                  message: '민수 : 일정 공유할게요!',
                                  time: '9/8',
                                  avatar: CoupleAvatar(),
                                ),
                              ],
                            ),
                            Positioned(
                              left: context.rs(18),
                              right: context.rs(18),
                              bottom: context.rs(12),
                              child: BottomNavigation(
                                currentIndex: currentIndex,
                                onItemSelected: onNavigationSelected,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
