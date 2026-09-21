import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../../models/trip_member.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/chat_avatars.dart';
import '../../widgets/common/responsive.dart';
import '../../services/ai_service.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.room,
    required this.accessToken,
    super.key,
  });

  final ChatRoom room;
  final String accessToken;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<List<ChatMessage>> _messagesFuture;
  late Future<List<TripMember>> _membersFuture;
  List<ChatMessage> _messages = const [];
  bool _isSending = false;
  bool _isRoomMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
    _membersFuture = _loadMembers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final message = await ChatService.sendMessage(
        accessToken: widget.accessToken,
        tripId: widget.room.tripId,
        content: content,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages = [..._messages, message];
        _messageController.clear();
        _isSending = false;
      });

      _scrollToBottomSoon();
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
    final items = await AiService.analyzeChat(
      widget.room.tripId,
    );

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rs(28)),
        ),
      ),
      builder: (context) => _AiSummarySheet(
        items: items,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI 요약에 실패했습니다: $e'),
      ),
    );
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

  Future<void> _inviteMember() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => const _InviteMemberDialog(),
    );

    if (!mounted || email == null || email.trim().isEmpty) {
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
          .showSnackBar(const SnackBar(content: Text('멤버를 초대했습니다.')));
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showPreparingMessage(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label 기능은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FC),
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
                              onSend: _sendMessage,
                            ),
                          ],
                        ),
                        if (_isRoomMenuOpen)
                          _RoomSideMenu(
                            membersFuture: _membersFuture,
                            onClose: _closeRoomMenu,
                            onInvite: _inviteMember,
                            onScheduleSummary: () {
                              _closeRoomMenu();
                              _openAiSummarySheet();
                            },
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
            child: CircularProgressIndicator(color: Color(0xFF635BFF)),
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
          padding: context.insetsFromLTRB(24, 16, 24, 20),
          itemBuilder: (context, index) {
            return _MessageBubble(message: _messages[index]);
          },
          separatorBuilder: (context, index) {
            return const ResponsiveGap(height: 14);
          },
          itemCount: _messages.length,
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
    return Padding(
      padding: context.insetsFromLTRB(12, 16, 14, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          _RoomAvatar(room: room),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(21),
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const ResponsiveGap(height: 5),
                Text(
                  _subtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF767E9A),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 8),
          _AiSummaryButton(onTap: onAiSummaryTap),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final dDay = _dDayLabel();

    if (dDay == null) {
      return '${room.memberCount}명 참여';
    }

    return '${room.memberCount}명 참여 · $dDay';
  }

  String? _dDayLabel() {
    final startDate = room.startDate;

    if (startDate == null) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final difference = start.difference(today).inDays;

    if (difference == 0) {
      return 'D-Day';
    }

    if (difference > 0) {
      return 'D-$difference';
    }

    return 'D+${difference.abs()}';
  }
}

class _RoomSideMenu extends StatelessWidget {
  const _RoomSideMenu({
    required this.membersFuture,
    required this.onClose,
    required this.onInvite,
    required this.onScheduleSummary,
    required this.onSettlement,
    required this.onFiles,
  });

  final Future<List<TripMember>> membersFuture;
  final VoidCallback onClose;
  final VoidCallback onInvite;
  final VoidCallback onScheduleSummary;
  final VoidCallback onSettlement;
  final VoidCallback onFiles;

  @override
  Widget build(BuildContext context) {
    final menuWidth = context.rs(250);

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
                  child: Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              ),
            ),
          ),
          Container(
            width: menuWidth,
            color: Colors.white,
            child: SafeArea(
              left: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RoomMenuAction(
                    icon: Icons.check_rounded,
                    label: '일정 요약',
                    onTap: onScheduleSummary,
                  ),
                  _RoomMenuAction(
                    icon: Icons.alternate_email_rounded,
                    label: '여행 정산',
                    onTap: onSettlement,
                  ),
                  _RoomMenuAction(
                    icon: Icons.image_outlined,
                    label: '사진 / 파일',
                    onTap: onFiles,
                  ),
                  Container(
                    height: context.rs(8),
                    color: const Color(0xFFE8E8EC),
                  ),
                  Expanded(
                    child: FutureBuilder<List<TripMember>>(
                      future: membersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF635BFF),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: context.symmetricInsets(horizontal: 18),
                              child: Text(
                                '멤버 목록을 불러오지 못했습니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF707891),
                                  fontSize: context.rs(14),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }

                        final members = snapshot.data ?? const <TripMember>[];

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return _RoomMemberTile(member: members[index]);
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(height: 1);
                          },
                          itemCount: members.length,
                        );
                      },
                    ),
                  ),
                  _InviteMemberButton(onTap: onInvite),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomMenuAction extends StatelessWidget {
  const _RoomMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.insetsFromLTRB(18, 16, 18, 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF121827), size: context.rs(24)),
            const ResponsiveGap(width: 16),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF121827),
                fontSize: context.rs(15),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomMemberTile extends StatelessWidget {
  const _RoomMemberTile({required this.member});

  final TripMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(14, 10, 12, 10),
      child: Row(
        children: [
          _MemberAvatar(name: member.nickname),
          const ResponsiveGap(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  member.owner ? 'Owner' : member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF858CA2),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w700,
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

class _InviteMemberButton extends StatelessWidget {
  const _InviteMemberButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE1E1E6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.insetsFromLTRB(16, 14, 16, 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: context.rs(18),
                backgroundColor: const Color(0xFF767B86),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: context.rs(19),
                ),
              ),
              const ResponsiveGap(width: 10),
              Text(
                '+ 초대',
                style: TextStyle(
                  color: const Color(0xFF121827),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog();

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('멤버 초대'),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: '이메일',
          hintText: 'member@example.com',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _emailController.text.trim());
          },
          child: const Text('초대'),
        ),
      ],
    );
  }
}

class _AiSummaryButton extends StatelessWidget {
  const _AiSummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
      label: const Text('AI 요약'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFECE8FF),
        foregroundColor: const Color(0xFF635BFF),
        padding: context.symmetricInsets(horizontal: 14, vertical: 10),
        textStyle: TextStyle(
          fontSize: context.rs(14),
          fontWeight: FontWeight.w900,
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
          _TimeText(sentAt: message.sentAt),
          const ResponsiveGap(width: 8),
          Flexible(
            child: Container(
              padding: context.symmetricInsets(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECE8FF),
                borderRadius: BorderRadius.circular(context.rs(20)),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: const Color(0xFF222747),
                  fontSize: context.rs(15),
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PersonBubbleAvatar(name: message.senderNickname),
        const ResponsiveGap(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderNickname,
                style: TextStyle(
                  color: const Color(0xFF6F7894),
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const ResponsiveGap(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: context.symmetricInsets(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEEF5),
                        borderRadius: BorderRadius.circular(context.rs(20)),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: const Color(0xFF222747),
                          fontSize: context.rs(15),
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  const ResponsiveGap(width: 8),
                  _TimeText(sentAt: message.sentAt),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeText extends StatelessWidget {
  const _TimeText({required this.sentAt});

  final DateTime sentAt;

  @override
  Widget build(BuildContext context) {
    final hour = sentAt.hour;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final minute = sentAt.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';

    return Text(
      '$period $displayHour:$minute',
      style: TextStyle(
        color: const Color(0xFF8B92AA),
        fontSize: context.rs(12),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          _RoundComposerButton(icon: Icons.add_rounded, onTap: () {}),
          const ResponsiveGap(width: 10),
          Expanded(
            child: Container(
              height: context.rs(54),
              padding: context.symmetricInsets(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.rs(27)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: context.rs(12),
                    offset: Offset(0, context.rs(4)),
                  ),
                ],
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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '메시지를 입력하세요...',
                        hintStyle: TextStyle(color: Color(0xFFA2A8BB)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Color(0xFF7F879E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ResponsiveGap(width: 10),
          _SendButton(isSending: isSending, onTap: onSend),
        ],
      ),
    );
  }
}

class _RoundComposerButton extends StatelessWidget {
  const _RoundComposerButton({required this.icon, required this.onTap});

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
          width: context.rs(54),
          height: context.rs(54),
          child: Icon(
            icon,
            color: const Color(0xFF121827),
            size: context.rs(32),
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
      color: const Color(0xFF635BFF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isSending ? null : onTap,
        child: SizedBox(
          width: context.rs(56),
          height: context.rs(56),
          child: isSending
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: context.rs(27),
                ),
        ),
      ),
    );
  }
}

class _AiSummarySheet extends StatelessWidget {
  final List<dynamic> items;

  const _AiSummarySheet({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: context.insetsFromLTRB(22, 14, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: context.rs(56),
                height: context.rs(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DAE4),
                  borderRadius: BorderRadius.circular(context.rs(6)),
                ),
              ),
            ),
            const ResponsiveGap(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF635BFF),
                  size: 30,
                ),
                const ResponsiveGap(width: 10),
                Expanded(
                  child: Text(
                    'AI 요약 결과',
                    style: TextStyle(
                      color: const Color(0xFF121827),
                      fontSize: context.rs(24),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const ResponsiveGap(height: 8),
            Text(
              '대화에서 추출한 항목을 확인 후 등록하세요.',
              style: TextStyle(
                color: const Color(0xFF66708E),
                fontSize: context.rs(15),
                fontWeight: FontWeight.w700,
              ),
            ),
            const ResponsiveGap(height: 18),
            const _SummaryItem(
              icon: Icons.calendar_month_rounded,
              title: '일정',
              content: '9/13 12:00 점심\n9/13 14:00 성산일출봉',
            ),
            const ResponsiveGap(height: 12),
            const _SummaryItem(
              icon: Icons.hotel_rounded,
              title: '예약',
              content: '제주 하얏트 리젠시 · 9/12 - 9/15',
            ),
            const ResponsiveGap(height: 12),
            const _SummaryItem(
              icon: Icons.payments_rounded,
              title: '정산',
              content: '렌터카 70,000원 · 4명 분담',
            ),
            const ResponsiveGap(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4C5574),
                      padding: context.symmetricInsets(vertical: 16),
                      side: const BorderSide(color: Color(0xFFCFC8FF)),
                    ),
                    child: const Text('닫기'),
                  ),
                ),
                const ResponsiveGap(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      foregroundColor: Colors.white,
                      padding: context.symmetricInsets(vertical: 16),
                    ),
                    child: const Text('선택한 내용 등록하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.rs(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: context.rs(18),
            offset: Offset(0, context.rs(8)),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box_rounded, color: Color(0xFF635BFF)),
          const ResponsiveGap(width: 14),
          CircleAvatar(
            radius: context.rs(27),
            backgroundColor: const Color(0xFFECE8FF),
            child: Icon(icon, color: const Color(0xFF635BFF)),
          ),
          const ResponsiveGap(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(16),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const ResponsiveGap(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    color: const Color(0xFF58617F),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('수정')),
        ],
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
            Icon(icon, color: const Color(0xFF635BFF), size: context.rs(42)),
            const ResponsiveGap(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF121827),
                fontSize: context.rs(18),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (message != null) ...[
              const ResponsiveGap(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF76809A),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w600,
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

class _RoomAvatar extends StatelessWidget {
  const _RoomAvatar({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
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

    return const GroupAvatar();
  }
}

class _PersonBubbleAvatar extends StatelessWidget {
  const _PersonBubbleAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1);

    return CircleAvatar(
      radius: context.rs(22),
      backgroundColor: const Color(0xFFE0E4F0),
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF4B5470),
          fontSize: context.rs(15),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1);

    return CircleAvatar(
      radius: context.rs(22),
      backgroundColor: const Color(0xFFE5E2D5),
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF4E5148),
          fontSize: context.rs(15),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
