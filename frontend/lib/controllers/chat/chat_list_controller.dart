import 'package:flutter/foundation.dart';

import '../../models/chat_room.dart';
import '../../services/chat_service.dart';

class ChatListController extends ChangeNotifier {
  ChatListController({
    required this.accessToken,
    Future<List<ChatRoom>> Function(String accessToken)? roomLoader,
  }) : _roomLoader =
           roomLoader ??
           ((token) => ChatService.fetchChatRooms(accessToken: token));

  String accessToken;
  final Future<List<ChatRoom>> Function(String accessToken) _roomLoader;
  late Future<List<ChatRoom>> roomsFuture;
  bool _initialized = false;
  bool _disposed = false;

  void initialize() {
    if (_initialized || _disposed) return;
    _initialized = true;
    roomsFuture = _roomLoader(accessToken);
  }

  void reload({String? accessToken}) {
    if (_disposed) return;
    if (accessToken != null) this.accessToken = accessToken;
    roomsFuture = _roomLoader(this.accessToken);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
