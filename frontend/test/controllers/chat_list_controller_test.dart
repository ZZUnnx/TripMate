import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/chat_list_controller.dart';
import 'package:frontend/controllers/chat/create_chat_room_controller.dart';
import 'package:frontend/models/chat_room.dart';

const _room = ChatRoom(
  tripId: 1,
  title: 'test trip',
  unreadCount: 0,
  pinned: false,
  aiSummaryAvailable: false,
  memberCount: 2,
);

void main() {
  test('loads once, refreshes, and uses the updated access token', () async {
    final tokens = <String>[];
    final controller = ChatListController(
      accessToken: 'first',
      roomLoader: (token) async {
        tokens.add(token);
        return [_room];
      },
    );
    addTearDown(controller.dispose);
    controller.initialize();
    controller.initialize();
    expect(await controller.roomsFuture, [_room]);
    controller.reload();
    await controller.roomsFuture;
    controller.reload(accessToken: 'second');
    await controller.roomsFuture;
    controller.reload();
    await controller.roomsFuture;
    expect(tokens, ['first', 'first', 'second', 'second']);
  });

  test('retries failed requests and stops reloading after disposal', () async {
    var calls = 0;
    final controller = ChatListController(
      accessToken: 'test',
      roomLoader: (_) async {
        if (++calls == 1) throw StateError('request failed');
        return [];
      },
    );
    controller.initialize();
    await expectLater(controller.roomsFuture, throwsStateError);
    controller.reload();
    expect(await controller.roomsFuture, isEmpty);
    controller.dispose();
    controller.reload();
    expect(calls, 2);
  });

  test('trims titles and prevents empty or duplicate creation', () async {
    final pending = Completer<void>();
    final titles = <String>[];
    final controller = CreateChatRoomController(
      accessToken: 'test',
      roomCreator: (title) {
        titles.add(title);
        return pending.future;
      },
    );
    addTearDown(controller.dispose);
    expect(await controller.createRoom('  '), isFalse);
    final result = controller.createRoom(' trip ');
    expect(controller.isSaving, isTrue);
    expect(await controller.createRoom('duplicate'), isFalse);
    pending.complete();
    expect(await result, isTrue);
    expect(controller.isSaving, isFalse);
    expect(titles, ['trip']);
  });

  test(
    'restores saving state after failure so creation can be retried',
    () async {
      var attempts = 0;
      final controller = CreateChatRoomController(
        accessToken: 'test',
        roomCreator: (_) async {
          if (++attempts == 1) throw StateError('request failed');
        },
      );
      addTearDown(controller.dispose);
      await expectLater(controller.createRoom('trip'), throwsStateError);
      expect(controller.isSaving, isFalse);
      expect(await controller.createRoom('trip'), isTrue);
      expect(attempts, 2);
    },
  );

  test('ignores creation completed after the sheet is disposed', () async {
    final pending = Completer<void>();
    var notifications = 0;
    final controller = CreateChatRoomController(
      accessToken: 'test',
      roomCreator: (_) => pending.future,
    );
    controller.addListener(() => notifications++);
    final result = controller.createRoom('trip');
    expect(notifications, 1);
    controller.dispose();
    pending.complete();
    expect(await result, isFalse);
    expect(notifications, 1);
    expect(await controller.createRoom('after leaving'), isFalse);
  });
}
