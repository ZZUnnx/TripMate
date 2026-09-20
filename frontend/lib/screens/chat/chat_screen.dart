import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/chat_room.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import 'chat_detail_screen.dart';
import '../../widgets/chat/chat_avatars.dart';
import '../../widgets/chat/chat_header.dart';
import '../../widgets/chat/chat_room_card.dart';
import '../../widgets/chat/chat_section_header.dart';
import '../../widgets/common/card_decoration.dart';
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
                                ChatHeader(onCreateTap: _openCreateRoomSheet),
                                const ResponsiveGap(height: 30),
                                _ChatBody(refreshVersion: _refreshVersion),
                              ],
                            ),
                            Positioned(
                              left: context.rs(18),
                              right: context.rs(18),
                              bottom: context.rs(12),
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

class _CreateChatRoomSheet extends StatefulWidget {
  const _CreateChatRoomSheet({required this.accessToken});

  final String accessToken;

  @override
  State<_CreateChatRoomSheet> createState() => _CreateChatRoomSheetState();
}

class _CreateChatRoomSheetState extends State<_CreateChatRoomSheet> {
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final title = _titleController.text.trim();
    final destination = _destinationController.text.trim();

    if (title.isEmpty) {
      _showMessage('채팅방 이름을 입력해주세요.');
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _showMessage('종료일은 시작일보다 빠를 수 없습니다.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ChatService.createChatRoom(
        accessToken: widget.accessToken,
        title: title,
        destination: destination,
        startDate: _startDate,
        endDate: _endDate,
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

  Future<void> _pickDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? _startDate ?? now
        : _endDate ?? _startDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      if (isStartDate) {
        _startDate = pickedDate;

        if (_endDate != null && _endDate!.isBefore(pickedDate)) {
          _endDate = pickedDate;
        }
      } else {
        _endDate = pickedDate;
      }
    });
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
                hint: '예: 제주도 여행',
                textInputAction: TextInputAction.next,
              ),
              const ResponsiveGap(height: 14),
              _SheetTextField(
                controller: _destinationController,
                label: '여행지',
                hint: '예: 제주',
                textInputAction: TextInputAction.done,
              ),
              const ResponsiveGap(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateSelectButton(
                      label: '시작일',
                      value: _formatDateLabel(_startDate),
                      onTap: _isSaving
                          ? null
                          : () => _pickDate(isStartDate: true),
                    ),
                  ),
                  const ResponsiveGap(width: 10),
                  Expanded(
                    child: _DateSelectButton(
                      label: '종료일',
                      value: _formatDateLabel(_endDate),
                      onTap: _isSaving
                          ? null
                          : () => _pickDate(isStartDate: false),
                    ),
                  ),
                ],
              ),
              const ResponsiveGap(height: 24),
              SizedBox(
                width: double.infinity,
                height: context.rs(54),
                child: FilledButton(
                  onPressed: _isSaving ? null : _createRoom,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
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

  String _formatDateLabel(DateTime? date) {
    if (date == null) {
      return '선택';
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}.$month.$day';
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

class _DateSelectButton extends StatelessWidget {
  const _DateSelectButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_month_rounded),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: context.rs(12),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: context.rs(14),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF121827),
        padding: context.symmetricInsets(horizontal: 12, vertical: 12),
        side: const BorderSide(color: Color(0xFFE0E3EE)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.rs(14)),
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
