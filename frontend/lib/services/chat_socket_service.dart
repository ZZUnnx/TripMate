import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/chat_message.dart';
import 'auth_service.dart';

class ChatSocketService {
  ChatSocketService({
    required this.accessToken,
    required this.tripId,
    required this.currentUserId,
  });

  final String accessToken;
  final int tripId;
  final int currentUserId;

  final _messagesController = StreamController<ChatMessage>.broadcast();

  StompClient? _client;
  dynamic _unsubscribe;
  bool _isConnected = false;

  Stream<ChatMessage> get messages => _messagesController.stream;

  void connect() {
    if (_client != null) {
      return;
    }

    final authHeaders = {'Authorization': 'Bearer $accessToken'};

    _client = StompClient(
      config: StompConfig(
        url: _webSocketUrl(),
        stompConnectHeaders: authHeaders,
        webSocketConnectHeaders: authHeaders,
        reconnectDelay: const Duration(seconds: 5),
        onConnect: _onConnect,
        onDisconnect: (_) {
          _isConnected = false;
        },
        onWebSocketDone: () {
          _isConnected = false;
        },
        onWebSocketError: (error) {
          _isConnected = false;
          _messagesController.addError(error);
        },
        onStompError: (frame) {
          _messagesController.addError(frame.body ?? 'STOMP error');
        },
      ),
    );

    _client!.activate();
  }

  void sendMessage(String content) {
    final client = _client;

    if (client == null || !_isConnected) {
      throw StateError('Chat socket is not connected.');
    }

    client.send(
      destination: '/app/trips/$tripId/messages',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
  }

  void dispose() {
    final unsubscribe = _unsubscribe;

    if (unsubscribe is Function) {
      unsubscribe();
    }

    _client?.deactivate();
    _client = null;
    _isConnected = false;
    _messagesController.close();
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;

    _unsubscribe = _client?.subscribe(
      destination: '/topic/trips/$tripId/messages',
      callback: (frame) {
        final body = frame.body;

        if (body == null || body.isEmpty) {
          return;
        }

        final decoded = jsonDecode(body);

        if (decoded is! Map<String, dynamic>) {
          _messagesController.addError(
            const FormatException('Invalid chat message payload.'),
          );
          return;
        }

        _messagesController.add(
          ChatMessage.fromJson(decoded, currentUserId: currentUserId),
        );
      },
    );
  }

  String _webSocketUrl() {
    final baseUri = Uri.parse(AuthService.baseUrl);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';

    return baseUri.replace(scheme: scheme, path: '/ws/chat').toString();
  }
}
