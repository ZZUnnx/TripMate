class TripMember {
  const TripMember({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.role,
    required this.owner,
    this.joinedAt,
  });

  final int userId;
  final String email;
  final String nickname;
  final String role;
  final bool owner;
  final DateTime? joinedAt;

  factory TripMember.fromJson(Map<String, dynamic> json) {
    return TripMember(
      userId: _readInt(json['userId'], 'userId'),
      email: _readString(json['email'], 'email'),
      nickname: _readString(json['nickname'], 'nickname'),
      role: _readString(json['role'], 'role'),
      owner: json['owner'] == true,
      joinedAt: _readDateTime(json['joinedAt']),
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

  static DateTime? _readDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
