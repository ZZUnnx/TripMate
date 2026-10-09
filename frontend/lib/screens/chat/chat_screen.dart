import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/chat_room.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import 'chat_detail_screen.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';

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
        return _CreateChatRoomSheet(accessToken: auth.accessToken!);
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
                                _ChatListHeader(
                                  onMoreTap: _openCreateRoomSheet,
                                ),
                                const ResponsiveGap(height: 10),
                                const _ChatSearchBar(),
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

class _ChatListHeader extends StatelessWidget {
  const _ChatListHeader({required this.onMoreTap});

  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여행 채팅',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  '최근 대화순으로 모든 채팅방을 한눈에 확인해요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 12),
          _HeaderCircleButton(icon: Icons.add_rounded, onTap: onMoreTap),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: Icon(
            icon,
            color: const Color(0xFF152523),
            size: context.rs(18),
          ),
        ),
      ),
    );
  }
}

class _ChatSearchBar extends StatelessWidget {
  const _ChatSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(42),
      padding: context.symmetricInsets(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF8A9895),
            size: context.rs(16),
          ),
          const ResponsiveGap(width: 8),
          Expanded(
            child: Text(
              '여행명, 장소, 메시지 검색',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF8A9895),
                fontSize: context.rs(13),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
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
    return [
      _ChatSectionHeader(title: '전체 채팅', count: rooms.length),
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
        _ChatRoomRow(
          title: room.title,
          message: _previewMessage(room),
          date: _formatRoomDate(room.activityAt),
          time: _formatRoomClock(room.activityAt),
          badgeText: room.aiSummaryAvailable ? 'AI 요약' : '${room.memberCount}명',
          avatarLabel: _avatarLabelFor(room),
          avatarColor: _avatarColorFor(room),
          badgeStyle: room.aiSummaryAvailable
              ? _ChatBadgeStyle.coral
              : _ChatBadgeStyle.mint,
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

class _ChatSectionHeader extends StatelessWidget {
  const _ChatSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(14),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$count개',
          style: TextStyle(
            color: const Color(0xFF0B5F55),
            fontSize: context.rs(11),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

enum _ChatBadgeStyle { mint, neutral, coral }

class _ChatRoomRow extends StatelessWidget {
  const _ChatRoomRow({
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.badgeText,
    required this.avatarLabel,
    required this.avatarColor,
    required this.badgeStyle,
    required this.onTap,
  });

  final String title;
  final String message;
  final String date;
  final String time;
  final String badgeText;
  final String avatarLabel;
  final Color avatarColor;
  final _ChatBadgeStyle badgeStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Ink(
          padding: context.symmetricInsets(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(12)),
          ),
          child: Row(
            children: [
              _ChatAvatar(label: avatarLabel, color: avatarColor),
              const ResponsiveGap(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF152523),
                              fontSize: context.rs(15),
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const ResponsiveGap(width: 8),
                        Text(
                          date,
                          maxLines: 1,
                          style: TextStyle(
                            color: const Color(0xFF8A9895),
                            fontSize: context.rs(10),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const ResponsiveGap(height: 6),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF60706D),
                        fontSize: context.rs(13),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const ResponsiveGap(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ChatBadge(text: badgeText, style: badgeStyle),
                        Text(
                          time,
                          style: TextStyle(
                            color: const Color(0xFF8A9895),
                            fontSize: context.rs(10),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(40),
      height: context.rs(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: context.rs(2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(label.length > 1 ? 11 : 12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatBadge extends StatelessWidget {
  const _ChatBadge({required this.text, required this.style});

  final String text;
  final _ChatBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      _ChatBadgeStyle.mint => (
        background: const Color(0xFFDDF3EE),
        foreground: const Color(0xFF0B5F55),
      ),
      _ChatBadgeStyle.neutral => (
        background: const Color(0xFFEEF3F2),
        foreground: const Color(0xFF60706D),
      ),
      _ChatBadgeStyle.coral => (
        background: const Color(0xFFFFF0EC),
        foreground: const Color(0xFFF27864),
      ),
    };

    return Container(
      padding: context.symmetricInsets(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(context.rs(999)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.foreground,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _CreateChatRoomSheet extends StatefulWidget {
  const _CreateChatRoomSheet({required this.accessToken});

  final String accessToken;

  @override
  State<_CreateChatRoomSheet> createState() => _CreateChatRoomSheetState();
}

class _CreateChatRoomSheetState extends State<_CreateChatRoomSheet> {
  final _titleController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('채팅방 이름을 입력해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ChatService.createChatRoom(
        accessToken: widget.accessToken,
        title: title,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: context.insetsFromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '채팅방 만들기',
                      style: TextStyle(
                        color: const Color(0xFF121827),
                        fontSize: context.rs(22),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const ResponsiveGap(height: 18),
              _SheetTextField(
                controller: _titleController,
                label: '채팅방 이름',
                hint: '예: 테스트방',
                textInputAction: TextInputAction.done,
              ),
              const ResponsiveGap(height: 24),
              SizedBox(
                width: double.infinity,
                height: context.rs(54),
                child: FilledButton(
                  onPressed: _isSaving ? null : _createRoom,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF148776),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '만들기',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.rs(14)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(vertical: 52),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0B5F55)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0B5F55), size: context.rs(36)),
          const ResponsiveGap(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(18),
              fontWeight: FontWeight.w700,
            ),
          ),
          const ResponsiveGap(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const ResponsiveGap(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B5F55),
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
