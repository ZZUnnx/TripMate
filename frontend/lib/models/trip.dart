class Trip {
  const Trip({
    required this.id,
    required this.title,
    this.destination,
    this.startDate,
    this.endDate,
    this.ownerId,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? ownerId;
  final DateTime? createdAt;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: _readInt(json['id'], 'id'),
      title: _readString(json['title'], 'title'),
      destination: _readNullableString(json['destination']),
      startDate: _readDate(json['startDate']),
      endDate: _readDate(json['endDate']),
      ownerId: _readNullableInt(json['ownerId']),
      createdAt: _readDate(json['createdAt']),
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

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  static String _readString(Object? value, String fieldName) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw FormatException('$fieldName 값이 올바르지 않습니다.');
  }

  static String? _readNullableString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
