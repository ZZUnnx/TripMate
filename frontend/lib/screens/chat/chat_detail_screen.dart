import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../../models/trip_member.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../services/chat_service.dart';
import '../../services/chat_socket_service.dart';
import '../../services/schedule_service.dart';
import '../../widgets/common/responsive.dart';
import '../../services/ai_service.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.room,
    required this.accessToken,
    required this.currentUserId,
    super.key,
  });

  final ChatRoom room;
  final String accessToken;
  final int currentUserId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<List<ChatMessage>> _messagesFuture;
  late Future<List<TripMember>> _membersFuture;
  late ChatSocketService _chatSocketService;
  List<ChatMessage> _messages = const [];
  bool _isSending = false;
  bool _isRoomMenuOpen = false;
  bool _isAttachmentMenuOpen = false;
  StreamSubscription<ChatMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
    _membersFuture = _loadMembers();
    _chatSocketService = ChatSocketService(
      accessToken: widget.accessToken,
      tripId: widget.room.tripId,
      currentUserId: widget.currentUserId,
    );
    _messageSubscription = _chatSocketService.messages.listen(
      _appendMessage,
      onError: _showSocketError,
    );
    _chatSocketService.connect();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _chatSocketService.dispose();
    super.dispose();
  }

  Future<List<ChatMessage>> _loadMessages() async {
    final messages = await ChatService.fetchMessages(
      accessToken: widget.accessToken,
      tripId: widget.room.tripId,
    );

    _messages = messages;
    _scrollToBottomSoon();

    return messages;
  }

  Future<List<TripMember>> _loadMembers() {
    return ChatService.fetchMembers(
      accessToken: widget.accessToken,
      tripId: widget.room.tripId,
    );
  }

  Future<void> _openSharedSchedule() async {
    _closeRoomMenu();

    try {
      final schedules = await ScheduleService.fetchTripSchedules(
        accessToken: widget.accessToken,
        tripId: widget.room.tripId,
      );

      if (!mounted) {
        return;
      }

      if (schedules.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('공유 일정이 아직 없어요.')));
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TripCalendarDetailScreen(
            currentIndex: 1,
            onNavigationSelected: null,
            schedules: schedules,
            selectedSchedule: schedules.first,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('공유 일정을 불러오지 못했습니다. $error')));
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      _chatSocketService.sendMessage(content);

      if (!mounted) {
        return;
      }

      setState(() {
        _messageController.clear();
        _isSending = false;
        _isAttachmentMenuOpen = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _appendMessage(ChatMessage message) {
    if (!mounted || _messages.any((item) => item.id == message.id)) {
      return;
    }

    setState(() {
      _messages = [..._messages, message];
    });

    _scrollToBottomSoon();
  }

  void _showSocketError(Object error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
  }

  void _retry() {
    setState(() {
      _messagesFuture = _loadMessages();
    });
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openAiSummarySheet() async {
    try {
      final items = await AiService.analyzeChat(widget.room.tripId);

      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        barrierColor: const Color(0xFF152523).withValues(alpha: 0.4),
        backgroundColor: Colors.transparent,
        builder: (context) => _AiSummarySheet(items: items),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('AI 요약에 실패했습니다: $e')));
    }
  }

  void _openRoomMenu() {
    setState(() {
      _membersFuture = _loadMembers();
      _isRoomMenuOpen = true;
    });
  }

  void _closeRoomMenu() {
    setState(() {
      _isRoomMenuOpen = false;
    });
  }

  Future<void> _openInviteMemberSheet() async {
    final email = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      barrierColor: const Color(0xFF152523).withValues(alpha: 0.4),
      backgroundColor: Colors.transparent,
      builder: (context) => const _InviteMemberSheet(),
    );

    if (email == null || email.trim().isEmpty || !mounted) {
      return;
    }

    try {
      await ChatService.inviteMember(
        accessToken: widget.accessToken,
        tripId: widget.room.tripId,
        email: email.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _membersFuture = _loadMembers();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('친구를 초대했어요.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  void _showPreparingMessage(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label 기능은 준비 중입니다.')));
  }

  void _toggleAttachmentMenu() {
    setState(() {
      _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
    });
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
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            _ChatDetailHeader(
                              room: widget.room,
                              onBack: () => Navigator.pop(context),
                              onAiSummaryTap: _openAiSummarySheet,
                              onMenuTap: _openRoomMenu,
                            ),
                            Expanded(child: _buildMessageArea()),
                            _MessageComposer(
                              controller: _messageController,
                              isSending: _isSending,
                              isExpanded: _isAttachmentMenuOpen,
                              onAddTap: _toggleAttachmentMenu,
                              onSend: _sendMessage,
                            ),
                            if (_isAttachmentMenuOpen)
                              _AttachmentMenu(
                                onAiSummaryTap: _openAiSummarySheet,
                                onActionTap: _showPreparingMessage,
                              ),
                          ],
                        ),
                        if (_isRoomMenuOpen)
                          _RoomSideMenu(
                            room: widget.room,
                            membersFuture: _membersFuture,
                            onClose: _closeRoomMenu,
                            onInviteMember: _openInviteMemberSheet,
                            onScheduleSummary: () {
                              _closeRoomMenu();
                              _openAiSummarySheet();
                            },
                            onSharedSchedule: _openSharedSchedule,
                            onSettlement: () {
                              _closeRoomMenu();
                              _showPreparingMessage('여행 정산');
                            },
                            onFiles: () {
                              _closeRoomMenu();
                              _showPreparingMessage('사진 / 파일');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessageArea() {
    return FutureBuilder<List<ChatMessage>>(
      future: _messagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF148776)),
          );
        }

        if (snapshot.hasError && _messages.isEmpty) {
          return _MessageState(
            icon: Icons.wifi_off_rounded,
            title: '메시지를 불러오지 못했습니다',
            actionLabel: '다시 시도',
            onAction: _retry,
          );
        }

        if (_messages.isEmpty) {
          return const _MessageState(
            icon: Icons.forum_outlined,
            title: '아직 메시지가 없습니다',
            message: '첫 메시지를 보내 대화를 시작해보세요.',
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: context.insetsFromLTRB(16, 6, 16, 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ConversationIntro(message: _messages.first);
            }

            return _MessageBubble(message: _messages[index - 1]);
          },
          separatorBuilder: (context, index) {
            return const ResponsiveGap(height: 8);
          },
          itemCount: _messages.length + 1,
        );
      },
    );
  }
}

class _ChatDetailHeader extends StatelessWidget {
  const _ChatDetailHeader({
    required this.room,
    required this.onBack,
    required this.onAiSummaryTap,
    required this.onMenuTap,
  });

  final ChatRoom room;
  final VoidCallback onBack;
  final VoidCallback onAiSummaryTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Padding(
        padding: context.symmetricInsets(horizontal: 16),
        child: Row(
          children: [
            _HeaderCircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBack,
            ),
            const ResponsiveGap(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF152523),
                      fontSize: context.rs(18),
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const ResponsiveGap(height: 2),
                  Text(
                    '${room.memberCount}명',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF60706D),
                      fontSize: context.rs(11),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const ResponsiveGap(width: 10),
            _AiSummaryButton(onTap: onAiSummaryTap),
            const ResponsiveGap(width: 10),
            _HeaderCircleButton(icon: Icons.search_rounded, onTap: () {}),
            const ResponsiveGap(width: 10),
            _HeaderCircleButton(icon: Icons.menu_rounded, onTap: onMenuTap),
          ],
        ),
      ),
    );
  }
}

class _RoomSideMenu extends StatelessWidget {
  const _RoomSideMenu({
    required this.room,
    required this.membersFuture,
    required this.onClose,
    required this.onInviteMember,
    required this.onScheduleSummary,
    required this.onSharedSchedule,
    required this.onSettlement,
    required this.onFiles,
  });

  final ChatRoom room;
  final Future<List<TripMember>> membersFuture;
  final VoidCallback onClose;
  final VoidCallback onInviteMember;
  final VoidCallback onScheduleSummary;
  final VoidCallback onSharedSchedule;
  final VoidCallback onSettlement;
  final VoidCallback onFiles;

  @override
  Widget build(BuildContext context) {
    final menuWidth = context.rs(326);

    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: const Color(0xFF102724).withValues(alpha: 0.44),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: menuWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2E28).withValues(alpha: 0.16),
                  blurRadius: context.rs(30),
                  offset: Offset(0, context.rs(10)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  left: false,
                  bottom: false,
                  child: SizedBox(
                    height: context.rs(54),
                    child: Padding(
                      padding: context.symmetricInsets(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '채팅방 정보',
                              style: TextStyle(
                                color: const Color(0xFF152523),
                                fontSize: context.rs(13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _DrawerCloseButton(onTap: onClose),
                        ],
                      ),
                    ),
                  ),
                ),
                _DrawerTripFeature(room: room),
                Expanded(
                  child: SingleChildScrollView(
                    padding: context.insetsFromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DrawerParticipants(
                          membersFuture: membersFuture,
                          onInvite: onInviteMember,
                        ),
                        const ResponsiveGap(height: 13),
                        const _DrawerDivider(),
                        const ResponsiveGap(height: 10),
                        _DrawerMenuItem(
                          icon: Icons.campaign_outlined,
                          label: '공지',
                          trailing: '1',
                          onTap: onScheduleSummary,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.calendar_month_outlined,
                          label: '공유 일정',
                          trailing: '5개',
                          onTap: onSharedSchedule,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.photo_library_outlined,
                          label: '여행 앨범',
                          trailing: '24장',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.insert_drive_file_outlined,
                          label: '파일',
                          trailing: '3개',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.link_rounded,
                          label: '링크',
                          trailing: '7개',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: '정산 현황',
                          trailing: '진행 중',
                          onTap: onSettlement,
                        ),
                        const ResponsiveGap(height: 10),
                        const _DrawerDivider(),
                        const ResponsiveGap(height: 10),
                        _DrawerMenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: '알림 설정',
                          trailing: '켜짐',
                          onTap: () {},
                        ),
                        _DrawerMenuItem(
                          icon: Icons.logout_rounded,
                          label: '채팅방 나가기',
                          isDestructive: true,
                          showChevron: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerCloseButton extends StatelessWidget {
  const _DrawerCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF3F2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(32),
          height: context.rs(32),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFF152523),
            size: context.rs(17),
          ),
        ),
      ),
    );
  }
}

class _DrawerTripFeature extends StatelessWidget {
  const _DrawerTripFeature({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(128),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/chat_drawer_trip.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.03),
                  const Color(0xFF082E29).withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          Positioned(
            left: context.rs(16),
            right: context.rs(16),
            bottom: context.rs(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const ResponsiveGap(height: 3),
                Text(
                  _tripDateLabel(room),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tripDateLabel(ChatRoom room) {
    final startDate = room.startDate;
    final endDate = room.endDate;

    if (startDate == null || endDate == null) {
      return '${room.memberCount}명 참여';
    }

    final nights = endDate.difference(startDate).inDays;
    final days = nights + 1;

    return '${startDate.month}월 ${startDate.day}일 — ${endDate.month}월 ${endDate.day}일 · $nights박 $days일';
  }
}

class _DrawerParticipants extends StatelessWidget {
  const _DrawerParticipants({
    required this.membersFuture,
    required this.onInvite,
  });

  final Future<List<TripMember>> membersFuture;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TripMember>>(
      future: membersFuture,
      builder: (context, snapshot) {
        final members = snapshot.data ?? const <TripMember>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: context.rs(72),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF148776)),
            ),
          );
        }

        if (snapshot.hasError || members.isEmpty) {
          return Text(
            '참여자 정보를 불러오지 못했습니다.',
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(11),
              fontWeight: FontWeight.w500,
            ),
          );
        }

        final visibleMembers = members.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참여자 ${members.length}명',
              style: TextStyle(
                color: const Color(0xFF60706D),
                fontSize: context.rs(10),
                fontWeight: FontWeight.w700,
              ),
            ),
            const ResponsiveGap(height: 9),
            Row(
              children: [
                for (final member in visibleMembers)
                  Expanded(child: _DrawerParticipant(member: member)),
                Expanded(child: _DrawerInviteButton(onTap: onInvite)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DrawerInviteButton extends StatelessWidget {
  const _DrawerInviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Padding(
          padding: context.symmetricInsets(vertical: 2),
          child: Column(
            children: [
              Container(
                width: context.rs(40),
                height: context.rs(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3EE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBFE5DD),
                    width: context.rs(1),
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF0B5F55),
                  size: context.rs(17),
                ),
              ),
              const ResponsiveGap(height: 5),
              Text(
                '친구 초대',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerParticipant extends StatelessWidget {
  const _DrawerParticipant({required this.member});

  final TripMember member;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFDDF3EE),
      const Color(0xFFDDEEF9),
      const Color(0xFFFFE8D9),
      const Color(0xFFE8E1F7),
    ];
    final color = member.owner
        ? const Color(0xFFDDF3EE)
        : colors[member.nickname.hashCode.abs() % colors.length];

    return Column(
      children: [
        SizedBox(
          width: context.rs(40),
          height: context.rs(40),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: context.rs(19),
                backgroundColor: color,
                child: Text(
                  member.nickname.isEmpty ? '?' : member.nickname[0],
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (member.owner)
                Positioned(
                  right: context.rs(-1),
                  bottom: context.rs(-1),
                  child: Container(
                    width: context.rs(12),
                    height: context.rs(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B5F55),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const ResponsiveGap(height: 5),
        Text(
          member.owner ? '나' : member.nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFDCE6E3));
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? const Color(0xFFD95757)
        : const Color(0xFF152523);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: context.rs(38),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: context.rs(17)),
              const ResponsiveGap(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    color: const Color(0xFF8A9895),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (showChevron) ...[
                const ResponsiveGap(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF8A9895),
                  size: context.rs(14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteMemberSheet extends StatefulWidget {
  const _InviteMemberSheet();

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: context.insetsFromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF9),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(22)),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '친구 초대',
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _HeaderCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const ResponsiveGap(height: 6),
              Text(
                '초대할 친구의 이메일을 입력해 주세요.',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const ResponsiveGap(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'friend@example.com',
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF60706D),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: context.symmetricInsets(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(color: Color(0xFFDCE6E3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(
                      color: Color(0xFF148776),
                      width: 1.4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(color: Color(0xFFF27864)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(
                      color: Color(0xFFF27864),
                      width: 1.4,
                    ),
                  ),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }

                  if (!email.contains('@')) {
                    return '이메일 형식을 확인해주세요.';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const ResponsiveGap(height: 14),
              SizedBox(
                width: double.infinity,
                height: context.rs(46),
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: context.rs(17),
                  ),
                  label: const Text('초대하기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF148776),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rs(12)),
                    ),
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

class _AiSummaryButton extends StatelessWidget {
  const _AiSummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(999)),
        child: SizedBox(
          height: context.rs(34),
          child: Padding(
            padding: context.symmetricInsets(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: context.rs(14),
                ),
                const ResponsiveGap(width: 6),
                Text(
                  'AI 요약',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationIntro extends StatelessWidget {
  const _ConversationIntro({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: context.symmetricInsets(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF3F2),
          borderRadius: BorderRadius.circular(context.rs(999)),
        ),
        child: Text(
          _dateLabel(message.sentAt),
          style: TextStyle(
            color: const Color(0xFF60706D),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 $weekday요일';
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.mine) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _clockText(message.sentAt),
                style: TextStyle(
                  color: const Color(0xFF8A9895),
                  fontSize: context.rs(9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const ResponsiveGap(width: 7),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.rs(250)),
            child: Container(
              padding: context.symmetricInsets(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF148776),
                border: Border.all(color: const Color(0xFF148776)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.rs(13)),
                  topRight: Radius.circular(context.rs(4)),
                  bottomLeft: Radius.circular(context.rs(13)),
                  bottomRight: Radius.circular(context.rs(13)),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PersonBubbleAvatar(name: message.senderNickname),
        const ResponsiveGap(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.rs(256)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderNickname,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const ResponsiveGap(height: 4),
              Container(
                padding: context.symmetricInsets(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDCE6E3)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.rs(4)),
                    topRight: Radius.circular(context.rs(13)),
                    bottomLeft: Radius.circular(context.rs(13)),
                    bottomRight: Radius.circular(context.rs(13)),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const ResponsiveGap(width: 8),
        Text(
          _clockText(message.sentAt),
          style: TextStyle(
            color: const Color(0xFF8A9895),
            fontSize: context.rs(9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _clockText(DateTime sentAt) {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.isExpanded,
    required this.onAddTap,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isExpanded;
  final VoidCallback onAddTap;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(70),
      padding: context.insetsFromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
      ),
      child: Row(
        children: [
          _RoundComposerButton(
            icon: isExpanded ? Icons.close_rounded : Icons.add_rounded,
            isActive: isExpanded,
            onTap: onAddTap,
          ),
          const ResponsiveGap(width: 8),
          Expanded(
            child: Container(
              height: context.rs(38),
              padding: context.symmetricInsets(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF9),
                border: Border.all(color: const Color(0xFFDCE6E3)),
                borderRadius: BorderRadius.circular(context.rs(999)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: isExpanded
                            ? '사진, 일정, 정산을 함께 보내보세요'
                            : '메시지를 입력하세요',
                        hintStyle: TextStyle(color: Color(0xFF8A9895)),
                      ),
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: context.rs(24),
                      height: context.rs(24),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Color(0xFF8A9895),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ResponsiveGap(width: 8),
          _SendButton(isSending: isSending, onTap: onSend),
        ],
      ),
    );
  }
}

class _RoundComposerButton extends StatelessWidget {
  const _RoundComposerButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF148776) : const Color(0xFFEEF3F2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF60706D),
            size: context.rs(18),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isSending, required this.onTap});

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isSending ? null : onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: isSending
              ? const Padding(
                  padding: EdgeInsets.all(9),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: context.rs(17),
                ),
        ),
      ),
    );
  }
}

class _AttachmentMenu extends StatelessWidget {
  const _AttachmentMenu({
    required this.onAiSummaryTap,
    required this.onActionTap,
  });

  final VoidCallback onAiSummaryTap;
  final ValueChanged<String> onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.rs(96),
          width: double.infinity,
          padding: context.symmetricInsets(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAiSummaryTap,
              borderRadius: BorderRadius.circular(context.rs(16)),
              child: Row(
                children: [
                  Container(
                    width: context.rs(50),
                    height: context.rs(50),
                    decoration: BoxDecoration(
                      color: const Color(0xFF148776),
                      borderRadius: BorderRadius.circular(context.rs(16)),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.white,
                      size: context.rs(22),
                    ),
                  ),
                  const ResponsiveGap(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 요약',
                          style: TextStyle(
                            color: const Color(0xFF152523),
                            fontSize: context.rs(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const ResponsiveGap(height: 4),
                        Text(
                          '대화 내용을 일정과 정보로 정리해줘',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF60706D),
                            fontSize: context.rs(11),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: context.rs(262),
          width: double.infinity,
          padding: context.insetsFromLTRB(20, 22, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _AttachmentAction(
                    icon: Icons.image_outlined,
                    label: '사진',
                    backgroundColor: const Color(0xFFE1F2EE),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('사진'),
                  ),
                  _AttachmentAction(
                    icon: Icons.photo_camera_outlined,
                    label: '카메라',
                    backgroundColor: const Color(0xFFEAF0FB),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('카메라'),
                  ),
                  _AttachmentAction(
                    icon: Icons.insert_drive_file_outlined,
                    label: '파일',
                    backgroundColor: const Color(0xFFF0ECFA),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('파일'),
                  ),
                  _AttachmentAction(
                    icon: Icons.location_on_outlined,
                    label: '위치',
                    backgroundColor: const Color(0xFFFFF0EC),
                    iconColor: const Color(0xFF0B5F55),
                    badgeText: '준비 중',
                    onTap: () => onActionTap('위치'),
                  ),
                ],
              ),
              const ResponsiveGap(height: 20),
              Row(
                children: [
                  _AttachmentAction(
                    icon: Icons.calendar_month_outlined,
                    label: '일정',
                    backgroundColor: const Color(0xFFDDF3EE),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('일정'),
                  ),
                  _AttachmentAction(
                    icon: Icons.receipt_long_outlined,
                    label: '정산',
                    backgroundColor: const Color(0xFFFFF6DF),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('정산'),
                  ),
                  _AttachmentAction(
                    icon: Icons.bar_chart_rounded,
                    label: '투표',
                    backgroundColor: const Color(0xFFEAF0FB),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('투표'),
                  ),
                  _AttachmentAction(
                    icon: Icons.contacts_outlined,
                    label: '연락처',
                    backgroundColor: const Color(0xFFEEF3F2),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('연락처'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.rs(66),
                height: context.rs(55),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: context.rs(50),
                      height: context.rs(50),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(context.rs(16)),
                      ),
                      child: Icon(icon, color: iconColor, size: context.rs(22)),
                    ),
                    if (badgeText != null)
                      Positioned(
                        top: context.rs(-5),
                        right: context.rs(0),
                        child: Container(
                          padding: context.symmetricInsets(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A33D),
                            borderRadius: BorderRadius.circular(
                              context.rs(999),
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rs(8),
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const ResponsiveGap(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSummarySheet extends StatelessWidget {
  const _AiSummarySheet({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: context.rs(620),
        padding: context.insetsFromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(24)),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: context.rs(44),
              height: context.rs(4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE6E3),
                borderRadius: BorderRadius.circular(context.rs(999)),
              ),
            ),
            const ResponsiveGap(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 요약',
                        style: TextStyle(
                          color: const Color(0xFF152523),
                          fontSize: context.rs(18),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const ResponsiveGap(height: 2),
                      Text(
                        '현재까지 대화에서 찾은 정보를 검토하고 공유 일정에 추가해 주세요',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF60706D),
                          fontSize: context.rs(11),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _SheetCloseButton(onPressed: () => Navigator.pop(context)),
              ],
            ),
            const ResponsiveGap(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: context.symmetricInsets(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF9),
                        border: Border.all(color: const Color(0xFFCDEAE4)),
                        borderRadius: BorderRadius.circular(context.rs(12)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF18332E)
                                .withValues(alpha: 0.08),
                            blurRadius: context.rs(24),
                            offset: Offset(0, context.rs(8)),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const _SummaryHeader(),
                          const ResponsiveGap(height: 8),
                          const _SummaryItem(
                            icon: Icons.calendar_month_outlined,
                            iconBackground: Color(0xFFEAF0FB),
                            label: '날짜 · 시간',
                            value: '4월 19일(일) · 오전 9:00',
                          ),
                          const ResponsiveGap(height: 8),
                          const _SummaryItem(
                            icon: Icons.location_on_outlined,
                            iconBackground: Color(0xFFFFF0EC),
                            label: '장소',
                            value: '성산항 여객터미널',
                          ),
                          const ResponsiveGap(height: 8),
                          const _SummaryItem(
                            icon: Icons.confirmation_num_outlined,
                            iconBackground: Color(0xFFFFF6DF),
                            label: '예약',
                            value: '우도 왕복 배편 · 4명',
                          ),
                          const ResponsiveGap(height: 8),
                          const _SummaryItem(
                            icon: Icons.account_balance_wallet_outlined,
                            iconBackground: Color(0xFFEEF3F2),
                            label: '예산',
                            value: '1인 10,500원 · 총 42,000원',
                          ),
                          const ResponsiveGap(height: 8),
                          const _SummaryNotice(),
                          const ResponsiveGap(height: 8),
                          _SummaryPrimaryButton(
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const ResponsiveGap(height: 12),
                    _ReanalyzeButton(onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: context.rs(34),
          height: context.rs(34),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDCE6E3)),
          ),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFF60706D),
            size: context.rs(13),
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.rs(30),
          height: context.rs(30),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3EE),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: const Color(0xFF0B5F55),
            size: context.rs(15),
          ),
        ),
        const ResponsiveGap(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '5개 정보를 찾았어요',
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '추가 전 내용을 확인해 주세요',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: context.symmetricInsets(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3EE),
            borderRadius: BorderRadius.circular(context.rs(999)),
          ),
          child: Text(
            'AI 후보',
            style: TextStyle(
              color: const Color(0xFF0B5F55),
              fontSize: context.rs(9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(30),
            height: context.rs(30),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(context.rs(8)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0B5F55),
              size: context.rs(15),
            ),
          ),
          const ResponsiveGap(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 5),
          _SummaryCircleAction(icon: Icons.edit_outlined, onTap: () {}),
          const ResponsiveGap(width: 5),
          _SummaryCircleAction(icon: Icons.close_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _SummaryCircleAction extends StatelessWidget {
  const _SummaryCircleAction({required this.icon, required this.onTap});

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
          width: context.rs(26),
          height: context.rs(26),
          child: Icon(
            icon,
            color: const Color(0xFF60706D),
            size: context.rs(13),
          ),
        ),
      ),
    );
  }
}

class _SummaryNotice extends StatelessWidget {
  const _SummaryNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF3EE),
        borderRadius: BorderRadius.circular(context.rs(8)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: const Color(0xFF0B5F55),
            size: context.rs(14),
          ),
          const ResponsiveGap(width: 7),
          Expanded(
            child: Text(
              'AI가 자동 확정하지 않아요. 수정하거나 제외한 뒤 직접 추가해 주세요.',
              style: TextStyle(
                color: const Color(0xFF0B5F55),
                fontSize: context.rs(9),
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPrimaryButton extends StatelessWidget {
  const _SummaryPrimaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: SizedBox(
          height: context.rs(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: context.rs(16),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '공유 일정에 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReanalyzeButton extends StatelessWidget {
  const _ReanalyzeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: Container(
          height: context.rs(40),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_tethering_rounded,
                color: const Color(0xFF60706D),
                size: context.rs(16),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '다시 분석하기',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.symmetricInsets(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF148776), size: context.rs(42)),
            const ResponsiveGap(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF152523),
                fontSize: context.rs(18),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              const ResponsiveGap(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const ResponsiveGap(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonBubbleAvatar extends StatelessWidget {
  const _PersonBubbleAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1);
    final colors = [
      const Color(0xFFEAF0FB),
      const Color(0xFFFFE8D9),
      const Color(0xFFE8E1F7),
      const Color(0xFFFFF0EC),
    ];
    final color = colors[name.hashCode.abs() % colors.length];

    return CircleAvatar(
      radius: context.rs(14),
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
