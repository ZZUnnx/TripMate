import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/chat/chat_detail_controller.dart';
import '../../controllers/chat/ai_summary_controller.dart';
import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../../screens/calendar/trip_calendar_detail_screen.dart';
import '../settlement/settlement_screen.dart';
import '../../widgets/common/responsive.dart';

import '../../widgets/chat/detail/chat_detail_header.dart';
import '../../widgets/chat/detail/chat_room_side_menu.dart';
import '../../widgets/chat/detail/invite_member_sheet.dart';
import '../../widgets/chat/detail/chat_conversation_intro.dart';
import '../../widgets/chat/detail/chat_message_bubble.dart';
import '../../widgets/chat/detail/chat_message_composer.dart';
import '../../widgets/chat/detail/chat_attachment_menu.dart';
import '../../widgets/chat/detail/ai_summary_sheet.dart';
import '../../widgets/chat/detail/chat_message_state.dart';

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

  late final ChatDetailController _controller;
  bool _isRoomMenuOpen = false;
  bool _isAttachmentMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = ChatDetailController(
      accessToken: widget.accessToken,
      tripId: widget.room.tripId,
      currentUserId: widget.currentUserId,
      onMessageActivity: _scrollToBottomSoon,
      onSocketError: _showSocketError,
    );
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openSharedSchedule() async {
    _closeRoomMenu();

    try {
      final schedules = await _controller.loadSharedSchedules();

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
    try {
      final sent = _controller.sendMessage(_messageController.text);
      if (!mounted || !sent) return;
      setState(() {
        _messageController.clear();
        _isAttachmentMenuOpen = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showSocketError(Object error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
  }

  void _retry() => _controller.reloadMessages();

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
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
      final items = await _controller.analyzeChat();

      if (!mounted) return;

      final summaryController = AiSummaryController(
        items: items,
        tripId: widget.room.tripId,
        accessToken: widget.accessToken,
      );
      try {
        final savedCount = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          barrierColor: const Color(0xFF152523).withValues(alpha: 0.4),
          backgroundColor: Colors.transparent,
          builder: (context) => AiSummarySheet(
            controller: summaryController,
            currentUserId: widget.currentUserId,
          ),
        );
        if (!mounted || savedCount == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '일정 ${savedCount - summaryController.savedExpenseCount}개 · '
              '지출 ${summaryController.savedExpenseCount}개 저장 · '
              '기존 항목 ${summaryController.existingCount + summaryController.existingExpenseCount}개 제외',
            ),
          ),
        );
      } finally {
        summaryController.dispose();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('AI 요약에 실패했습니다: $e')));
    }
  }

  void _openRoomMenu() {
    _controller.reloadMembers();
    setState(() {
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
      builder: (context) => const InviteMemberSheet(),
    );

    if (email == null || email.trim().isEmpty || !mounted) {
      return;
    }

    try {
      await _controller.inviteMember(email);

      if (!mounted) {
        return;
      }

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
                            ChatDetailHeader(
                              room: widget.room,
                              onBack: () => Navigator.pop(context),
                              onAiSummaryTap: _openAiSummarySheet,
                              onMenuTap: _openRoomMenu,
                            ),
                            Expanded(child: _buildMessageArea()),
                            ChatMessageComposer(
                              controller: _messageController,
                              isSending: _controller.isSending,
                              isExpanded: _isAttachmentMenuOpen,
                              onAddTap: _toggleAttachmentMenu,
                              onSend: _sendMessage,
                            ),
                            if (_isAttachmentMenuOpen)
                              ChatAttachmentMenu(
                                onAiSummaryTap: _openAiSummarySheet,
                                onActionTap: _showPreparingMessage,
                              ),
                          ],
                        ),
                        if (_isRoomMenuOpen)
                          ChatRoomSideMenu(
                            room: widget.room,
                            membersFuture: _controller.membersFuture,
                            onClose: _closeRoomMenu,
                            onInviteMember: _openInviteMemberSheet,
                            onScheduleSummary: () {
                              _closeRoomMenu();
                              _openAiSummarySheet();
                            },
                            onSharedSchedule: _openSharedSchedule,
                            onSettlement: () {
                              _closeRoomMenu();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SettlementScreen(
                                    tripId: widget.room.tripId,
                                    tripTitle: widget.room.title,
                                    currentIndex: 1,
                                  ),
                                ),
                              );
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
    final messages = _controller.messages;
    return FutureBuilder<List<ChatMessage>>(
      future: _controller.messagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF148776)),
          );
        }

        if (snapshot.hasError && messages.isEmpty) {
          return ChatMessageState(
            icon: Icons.wifi_off_rounded,
            title: '메시지를 불러오지 못했습니다',
            actionLabel: '다시 시도',
            onAction: _retry,
          );
        }

        if (messages.isEmpty) {
          return const ChatMessageState(
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
              return ChatConversationIntro(message: messages.first);
            }

            return ChatMessageBubble(message: messages[index - 1]);
          },
          separatorBuilder: (context, index) {
            return const ResponsiveGap(height: 8);
          },
          itemCount: messages.length + 1,
        );
      },
    );
  }
}
