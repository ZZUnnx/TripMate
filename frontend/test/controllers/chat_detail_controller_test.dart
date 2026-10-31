import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/chat_detail_controller.dart';
import 'package:frontend/models/chat_message.dart';
import 'package:frontend/services/chat_socket_service.dart';

class _FakeSocket extends ChatSocketService {
  _FakeSocket() : super(accessToken: 'test', tripId: 1, currentUserId: 2);

  final events = StreamController<ChatMessage>.broadcast(sync: true);
  final sent = <String>[];
  int connections = 0;
  bool closed = false;
  bool failSend = false;

  @override
  Stream<ChatMessage> get messages => events.stream;

  @override
  void connect() => connections++;

  @override
  void sendMessage(String content) {
    if (failSend) throw StateError('disconnected');
    sent.add(content);
  }

  @override
  void dispose() {
    closed = true;
    events.close();
  }
}

ChatMessage _message(int id) => ChatMessage(
  id: id,
  tripId: 1,
  senderId: 2,
  senderNickname: 'tester',
  content: 'message $id',
  sentAt: DateTime(2026, 10, 31),
  mine: true,
);

void main() {
  test(
    'loads history, appends unique socket messages, and forwards errors',
    () async {
      final socket = _FakeSocket();
      var activity = 0;
      final errors = <Object>[];
      final controller = ChatDetailController(
        accessToken: 'test',
        tripId: 1,
        currentUserId: 2,
        socketService: socket,
        messageLoader: () async => [_message(1)],
        memberLoader: () async => [],
        onMessageActivity: () => activity++,
        onSocketError: errors.add,
      );
      addTearDown(controller.dispose);
      controller.initialize();
      controller.initialize();
      await controller.messagesFuture;
      await controller.membersFuture;

      socket.events.add(_message(1));
      socket.events.add(_message(2));
      final error = StateError('socket error');
      socket.events.addError(error);

      expect(socket.connections, 1);
      expect(controller.messages.map((message) => message.id), [1, 2]);
      expect(activity, 2);
      expect(errors, [error]);
    },
  );

  test('ignores blank sends and resets sending state after failure', () async {
    final socket = _FakeSocket();
    final controller = ChatDetailController(
      accessToken: 'test',
      tripId: 1,
      currentUserId: 2,
      socketService: socket,
      messageLoader: () async => [],
      memberLoader: () async => [],
      onMessageActivity: () {},
      onSocketError: (_) {},
    );
    addTearDown(controller.dispose);
    controller.initialize();
    await controller.messagesFuture;
    await controller.membersFuture;

    expect(controller.sendMessage('   '), isFalse);
    expect(controller.sendMessage(' hello '), isTrue);
    expect(socket.sent, ['hello']);
    socket.failSend = true;
    expect(() => controller.sendMessage('retry'), throwsStateError);
    expect(controller.isSending, isFalse);
    socket.failSend = false;
    expect(controller.sendMessage('retry'), isTrue);
  });

  test('retries failed history and refreshes members', () async {
    final socket = _FakeSocket();
    var messageLoads = 0;
    var memberLoads = 0;
    final controller = ChatDetailController(
      accessToken: 'test',
      tripId: 1,
      currentUserId: 2,
      socketService: socket,
      messageLoader: () async {
        if (++messageLoads == 1) throw StateError('request failed');
        return [_message(3)];
      },
      memberLoader: () async {
        memberLoads++;
        return [];
      },
      onMessageActivity: () {},
      onSocketError: (_) {},
    );
    addTearDown(controller.dispose);
    controller.initialize();
    await expectLater(controller.messagesFuture, throwsStateError);
    await controller.membersFuture;
    controller.reloadMessages();
    controller.reloadMembers();
    await controller.messagesFuture;
    await controller.membersFuture;

    expect(controller.messages.single.id, 3);
    expect(memberLoads, 2);
  });

  test('disposes socket and ignores history completed after leaving', () async {
    final socket = _FakeSocket();
    final pending = Completer<List<ChatMessage>>();
    var activity = 0;
    var notifications = 0;
    final controller = ChatDetailController(
      accessToken: 'test',
      tripId: 1,
      currentUserId: 2,
      socketService: socket,
      messageLoader: () => pending.future,
      memberLoader: () async => [],
      onMessageActivity: () => activity++,
      onSocketError: (_) {},
    );
    controller.addListener(() => notifications++);
    controller.initialize();
    await controller.membersFuture;
    controller.dispose();
    pending.complete([_message(1)]);
    await controller.messagesFuture;

    expect(socket.closed, isTrue);
    expect(controller.messages, isEmpty);
    expect(controller.sendMessage('after leaving'), isFalse);
    expect(activity, 0);
    expect(notifications, 0);
  });
}
