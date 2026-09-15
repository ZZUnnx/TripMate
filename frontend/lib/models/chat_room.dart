class ChatRoom {
  const ChatRoom({
    required this.tripId,
    required this.title,
    required this.unreadCount,
    required this.pinned,
    required this.aiSummaryAvailable,
    this.destination,
    this.lastMessage,
    this.lastSenderNickname,
    this.lastMessageAt,
  });

  final int tripId;
  final String title;
  final String? destination;
  final String? lastMessage;
  final String? lastSenderNickname;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool pinned;
  final bool aiSummaryAvailable;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      tripId: _readInt(json['tripId'], 'tripId'),
      title: _readString(json['title'], 'title'),
      destination: _readNullableString(json['destination']),
      lastMessage: _readNullableString(json['lastMessage']),
      lastSenderNickname: _readNullableString(json['lastSenderNickname']),
      lastMessageAt: _readDateTime(json['lastMessageAt']),
      unreadCount: _readInt(json['unreadCount'] ?? 0, 'unreadCount'),
      pinned: json['pinned'] == true,
      aiSummaryAvailable: json['aiSummaryAvailable'] == true,
    );
  }

  static int _readInt(Object? value, String fieldName) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    throw FormatException('$fieldName 값이 올바르지 않습니다.');
  }

  static String _readString(Object? value, String fieldName) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw FormatException('$fieldName 값이 올바르지 않습니다.');
  }

  static String? _readNullableString(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is String && value.isNotEmpty) {
      return value;
    }

    return null;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
