import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/chat_room.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import 'chat_detail_screen.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';

import '../../widgets/chat/chat_list_header.dart';
import '../../widgets/chat/chat_search_bar.dart';
import '../../widgets/chat/chat_list_section_header.dart';
import '../../widgets/chat/chat_room_row.dart';
import '../../widgets/chat/create_chat_room_sheet.dart';
import '../../widgets/chat/chat_list_states.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    this.currentIndex = 1,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _refreshVersion = 0;

  Future<void> _openCreateRoomSheet() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn || auth.accessToken == null || auth.userId == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rs(24)),
        ),
      ),
      builder: (context) {
        return CreateChatRoomSheet(accessToken: auth.accessToken!);
      },
    );

    if (!mounted || created != true) {
      return;
    }

    setState(() {
      _refreshVersion++;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('채팅방이 생성되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
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
                              padding: context.insetsFromLTRB(16, 10, 16, 92),
                              children: [
                                ChatListHeader(onMoreTap: _openCreateRoomSheet),
                                const ResponsiveGap(height: 10),
                                const ChatSearchBar(),
                                const ResponsiveGap(height: 12),
                                _ChatBody(refreshVersion: _refreshVersion),
                              ],
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: BottomNavigation(
                                currentIndex: widget.currentIndex,
                                onItemSelected: widget.onNavigationSelected,
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
  const _ChatBody({required this.refreshVersion});

  final int refreshVersion;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const ChatListLoadingState();
    }

    if (!auth.isLoggedIn || auth.accessToken == null) {
      return ChatListStateCard(
        icon: Icons.lock_outline_rounded,
        title: '로그인이 필요합니다',
        message: '여행 채팅방 목록을 보려면 먼저 로그인해주세요.',
        actionLabel: '로그인',
        onAction: () {
          Navigator.pushNamed(context, '/login');
        },
      );
    }

    return _ChatRoomList(
      accessToken: auth.accessToken!,
      currentUserId: auth.userId!,
      refreshVersion: refreshVersion,
    );
  }
}

class _ChatRoomList extends StatefulWidget {
  const _ChatRoomList({
    required this.accessToken,
    required this.currentUserId,
    required this.refreshVersion,
  });

  final String accessToken;
  final int currentUserId;
  final int refreshVersion;

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

    if (oldWidget.accessToken != widget.accessToken ||
        oldWidget.refreshVersion != widget.refreshVersion) {
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
          return const ChatListLoadingState();
        }

        if (snapshot.hasError) {
          return ChatListStateCard(
            icon: Icons.wifi_off_rounded,
            title: '채팅 목록을 불러오지 못했습니다',
            message: snapshot.error.toString(),
            actionLabel: '다시 시도',
            onAction: _retry,
          );
        }

        final rooms = snapshot.data ?? const <ChatRoom>[];

        if (rooms.isEmpty) {
          return const ChatListStateCard(
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
    return [
      ChatListSectionHeader(title: '전체 채팅', count: rooms.length),
      const ResponsiveGap(height: 8),
      ..._buildRoomCards(rooms),
    ];
  }

  List<Widget> _buildRoomCards(List<ChatRoom> rooms) {
    final children = <Widget>[];

    for (final room in rooms) {
      if (children.isNotEmpty) {
        children.add(const ResponsiveGap(height: 8));
      }

      children.add(
        ChatRoomRow(
          title: room.title,
          message: _previewMessage(room),
          date: _formatRoomDate(room.activityAt),
          time: _formatRoomClock(room.activityAt),
          badgeText: room.aiSummaryAvailable ? 'AI 요약' : '${room.memberCount}명',
          avatarLabel: _avatarLabelFor(room),
          avatarColor: _avatarColorFor(room),
          badgeStyle: room.aiSummaryAvailable
              ? ChatRoomBadgeStyle.coral
              : ChatRoomBadgeStyle.mint,
          onTap: () => _openChatRoom(room),
        ),
      );
    }

    return children;
  }

  Future<void> _openChatRoom(ChatRoom room) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) {
          return ChatDetailScreen(
            room: room,
            accessToken: widget.accessToken,
            currentUserId: widget.currentUserId,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    _retry();
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

    return '$sender · $message';
  }

  String _formatRoomDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();

    if (dateTime.year == now.year) {
      return '${dateTime.month}/${dateTime.day}';
    }

    return '${dateTime.year}.${dateTime.month}.${dateTime.day}';
  }

  String _formatRoomClock(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _avatarLabelFor(ChatRoom room) {
    final source = room.destination?.trim().isNotEmpty == true
        ? room.destination!.trim()
        : room.title.trim();

    if (source.isEmpty) {
      return '여';
    }

    final compact = source.replaceAll(' ', '');

    if (compact.length <= 2) {
      return compact;
    }

    return compact.characters.take(2).toString();
  }

  Color _avatarColorFor(ChatRoom room) {
    final colors = [
      const Color(0xFFDDEEF9),
      const Color(0xFFFFE8D9),
      const Color(0xFFEAF0FB),
      const Color(0xFFFFF6DF),
      const Color(0xFFDDF3EE),
    ];
    return colors[room.tripId.abs() % colors.length];
  }
}
