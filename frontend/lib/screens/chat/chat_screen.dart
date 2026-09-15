import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/chat_room.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/chat_avatars.dart';
import '../../widgets/chat/chat_header.dart';
import '../../widgets/chat/chat_room_card.dart';
import '../../widgets/chat/chat_section_header.dart';
import '../../widgets/common/card_decoration.dart';
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
                              children: [
                                const ChatHeader(),
                                const ResponsiveGap(height: 30),
                                const _ChatBody(),
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

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const _LoadingState();
    }

    if (!auth.isLoggedIn || auth.accessToken == null) {
      return _StateCard(
        icon: Icons.lock_outline_rounded,
        title: '로그인이 필요합니다',
        message: '여행 채팅방 목록을 보려면 먼저 로그인해주세요.',
        actionLabel: '로그인',
        onAction: () {
          Navigator.pushNamed(context, '/login');
        },
      );
    }

    return _ChatRoomList(accessToken: auth.accessToken!);
  }
}

class _ChatRoomList extends StatefulWidget {
  const _ChatRoomList({required this.accessToken});

  final String accessToken;

  @override
  State<_ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<_ChatRoomList> {
  late Future<List<ChatRoom>> _chatRoomsFuture;

  @override
  void initState() {
    super.initState();
    _chatRoomsFuture = _fetchChatRooms();
  }

  @override
  void didUpdateWidget(covariant _ChatRoomList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.accessToken != widget.accessToken) {
      _chatRoomsFuture = _fetchChatRooms();
    }
  }

  Future<List<ChatRoom>> _fetchChatRooms() {
    return ChatService.fetchChatRooms(accessToken: widget.accessToken);
  }

  void _retry() {
    setState(() {
      _chatRoomsFuture = _fetchChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatRoom>>(
      future: _chatRoomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        if (snapshot.hasError) {
          return _StateCard(
            icon: Icons.wifi_off_rounded,
            title: '채팅 목록을 불러오지 못했습니다',
            message: snapshot.error.toString(),
            actionLabel: '다시 시도',
            onAction: _retry,
          );
        }

        final rooms = snapshot.data ?? const <ChatRoom>[];

        if (rooms.isEmpty) {
          return const _StateCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: '아직 채팅방이 없습니다',
            message: '여행방을 만들거나 초대받으면 이곳에 채팅방이 표시됩니다.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildRoomSections(rooms),
        );
      },
    );
  }

  List<Widget> _buildRoomSections(List<ChatRoom> rooms) {
    final pinnedRooms = rooms.where((room) => room.pinned).toList();
    final recentRooms = rooms.where((room) => !room.pinned).toList();
    final children = <Widget>[];

    if (pinnedRooms.isNotEmpty) {
      children.add(
        const ChatSectionHeader(title: '고정된 채팅', showCollapseButton: true),
      );
      children.add(const ResponsiveGap(height: 12));
      children.addAll(_buildRoomCards(pinnedRooms));
      children.add(const ResponsiveGap(height: 28));
    }

    if (recentRooms.isNotEmpty) {
      children.add(const ChatSectionHeader(title: '최근 채팅'));
      children.add(const ResponsiveGap(height: 12));
      children.addAll(_buildRoomCards(recentRooms));
    }

    return children;
  }

  List<Widget> _buildRoomCards(List<ChatRoom> rooms) {
    final children = <Widget>[];

    for (final room in rooms) {
      if (children.isNotEmpty) {
        children.add(ResponsiveGap(height: room.pinned ? 10 : 1));
      }

      children.add(
        ChatRoomCard(
          title: room.title,
          message: _previewMessage(room),
          time: _formatRoomTime(room.lastMessageAt),
          badgeText: room.aiSummaryAvailable ? 'AI 요약 가능' : null,
          unreadCount: room.unreadCount > 0 ? room.unreadCount : null,
          isPinned: room.pinned,
          avatar: _avatarFor(room),
        ),
      );
    }

    return children;
  }

  String _previewMessage(ChatRoom room) {
    final message = room.lastMessage;

    if (message == null) {
      return '아직 메시지가 없습니다.';
    }

    final sender = room.lastSenderNickname;

    if (sender == null) {
      return message;
    }

    return '$sender : $message';
  }

  String _formatRoomTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDate(dateTime, now)) {
      final hour = dateTime.hour;
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? '오전' : '오후';

      return '$period $displayHour:$minute';
    }

    if (_isSameDate(dateTime, yesterday)) {
      return '어제';
    }

    if (dateTime.year == now.year) {
      return '${dateTime.month}/${dateTime.day}';
    }

    return '${dateTime.year}.${dateTime.month}.${dateTime.day}';
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  Widget _avatarFor(ChatRoom room) {
    final keyword = '${room.title} ${room.destination ?? ''}'.toLowerCase();

    if (keyword.contains('제주')) {
      return const TravelAvatar(style: TravelAvatarStyle.jeju);
    }

    if (keyword.contains('홋카이도') || keyword.contains('hokkaido')) {
      return const TravelAvatar(style: TravelAvatarStyle.hokkaido);
    }

    if (keyword.contains('부산')) {
      return const TravelAvatar(style: TravelAvatarStyle.busan);
    }

    if (keyword.contains('다낭') || keyword.contains('danang')) {
      return const TravelAvatar(style: TravelAvatarStyle.danang);
    }

    if (keyword.contains('가족')) {
      return const FamilyAvatar();
    }

    if (keyword.contains('팀') || keyword.contains('프로젝트')) {
      return const GroupAvatar();
    }

    if (keyword.contains('동남아') || keyword.contains('커플')) {
      return const CoupleAvatar();
    }

    return const PersonAvatar();
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(vertical: 52),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF635BFF)),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 20, vertical: 24),
      decoration: cardDecoration(context),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF635BFF), size: context.rs(36)),
          const ResponsiveGap(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF121827),
              fontSize: context.rs(18),
              fontWeight: FontWeight.w900,
            ),
          ),
          const ResponsiveGap(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF76809A),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const ResponsiveGap(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
