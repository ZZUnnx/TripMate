class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.senderNickname,
    required this.content,
    required this.sentAt,
    required this.mine,
  });

  final int id;
  final int tripId;
  final int senderId;
  final String senderNickname;
  final String content;
  final DateTime sentAt;
  final bool mine;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _readInt(json['id'], 'id'),
      tripId: _readInt(json['tripId'], 'tripId'),
      senderId: _readInt(json['senderId'], 'senderId'),
      senderNickname: _readString(json['senderNickname'], 'senderNickname'),
      content: _readString(json['content'], 'content'),
      sentAt: _readDateTime(json['sentAt']),
      mine: json['mine'] == true,
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

  static DateTime _readDateTime(Object? value) {
    final parsed = DateTime.tryParse(value.toString());

    if (parsed != null) {
      return parsed;
    }

    throw const FormatException('sentAt 값이 올바르지 않습니다.');
  }
}
