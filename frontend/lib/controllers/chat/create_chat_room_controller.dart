import 'package:flutter/foundation.dart';

import '../../services/chat_service.dart';

class CreateChatRoomController extends ChangeNotifier {
  CreateChatRoomController({
    required String accessToken,
    Future<void> Function(String title)? roomCreator,
  }) : _roomCreator =
           roomCreator ??
           ((title) => ChatService.createChatRoom(
             accessToken: accessToken,
             title: title,
           ));

  final Future<void> Function(String title) _roomCreator;
  bool _isSaving = false;
  bool _disposed = false;

  bool get isSaving => _isSaving;

  Future<bool> createRoom(String title) async {
    final trimmed = title.trim();
    if (_disposed || _isSaving || trimmed.isEmpty) return false;
    _isSaving = true;
    notifyListeners();
    try {
      await _roomCreator(trimmed);
      return !_disposed;
    } finally {
      _isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
