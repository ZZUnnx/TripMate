import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/chat_message.dart';
import '../../models/trip_member.dart';
import '../../models/trip_schedule.dart';
import '../../services/ai_service.dart';
import '../../services/chat_service.dart';
import '../../services/chat_socket_service.dart';
import '../../services/schedule_service.dart';

class ChatDetailController extends ChangeNotifier {
  ChatDetailController({
    required this.accessToken,
    required this.tripId,
    required int currentUserId,
    required this.onMessageActivity,
    required this.onSocketError,
    ChatSocketService? socketService,
    Future<List<ChatMessage>> Function()? messageLoader,
    Future<List<TripMember>> Function()? memberLoader,
  }) : _socketService =
           socketService ??
           ChatSocketService(
             accessToken: accessToken,
             tripId: tripId,
             currentUserId: currentUserId,
           ),
       _messageLoader =
           messageLoader ??
           (() => ChatService.fetchMessages(
             accessToken: accessToken,
             tripId: tripId,
           )),
       _memberLoader =
           memberLoader ??
           (() => ChatService.fetchMembers(
             accessToken: accessToken,
             tripId: tripId,
           ));

  final String accessToken;
  final int tripId;
  final VoidCallback onMessageActivity;
  final ValueChanged<Object> onSocketError;
  final ChatSocketService _socketService;
  final Future<List<ChatMessage>> Function() _messageLoader;
  final Future<List<TripMember>> Function() _memberLoader;

  late Future<List<ChatMessage>> messagesFuture;
  late Future<List<TripMember>> membersFuture;
  List<ChatMessage> _messages = const [];
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isSending = false;
  bool _initialized = false;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  void initialize() {
    if (_initialized || _disposed) return;
    _initialized = true;
    messagesFuture = _loadMessages();
    membersFuture = _memberLoader();
    _messageSubscription = _socketService.messages.listen(
      _appendMessage,
      onError: (Object error) {
        if (!_disposed) onSocketError(error);
      },
    );
    _socketService.connect();
  }

  Future<List<ChatMessage>> _loadMessages() async {
    final messages = await _messageLoader();
    if (!_disposed) {
      _messages = messages;
      notifyListeners();
      onMessageActivity();
    }
    return messages;
  }

  void reloadMessages() {
    if (_disposed) return;
    messagesFuture = _loadMessages();
    notifyListeners();
  }

  void reloadMembers() {
    if (_disposed) return;
    membersFuture = _memberLoader();
    notifyListeners();
  }

  bool sendMessage(String content) {
    final trimmed = content.trim();
    if (_disposed || trimmed.isEmpty || _isSending) return false;
    _isSending = true;
    notifyListeners();
    try {
      _socketService.sendMessage(trimmed);
      return true;
    } finally {
      _isSending = false;
      if (!_disposed) notifyListeners();
    }
  }

  void _appendMessage(ChatMessage message) {
    if (_disposed || _messages.any((item) => item.id == message.id)) return;
    _messages = [..._messages, message];
    notifyListeners();
    onMessageActivity();
  }

  Future<List<TripSchedule>> loadSharedSchedules() {
    return ScheduleService.fetchTripSchedules(
      accessToken: accessToken,
      tripId: tripId,
    );
  }

  Future<List<dynamic>> analyzeChat() => AiService.analyzeChat(tripId);

  Future<void> inviteMember(String email) async {
    await ChatService.inviteMember(
      accessToken: accessToken,
      tripId: tripId,
      email: email.trim(),
    );
    reloadMembers();
  }

  @override
  void dispose() {
    _disposed = true;
    _messageSubscription?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}
