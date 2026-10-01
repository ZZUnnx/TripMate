class TripSchedule {
  const TripSchedule({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.title,
    required this.scheduledDate,
    required this.category,
    required this.sortOrder,
    this.tripDestination,
    this.tripStartDate,
    this.tripEndDate,
    this.scheduledTime,
    this.placeName,
    this.url,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int tripId;
  final String tripTitle;
  final String? tripDestination;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String title;
  final String category;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final String? placeName;
  final String? url;
  final String? description;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TripSchedule.fromJson(Map<String, dynamic> json) {
    return TripSchedule(
      id: _readInt(json['id'], 'id'),
      tripId: _readInt(json['tripId'], 'tripId'),
      tripTitle: _readString(json['tripTitle'], 'tripTitle'),
      tripDestination: _readNullableString(json['tripDestination']),
      tripStartDate: _readDate(json['tripStartDate']),
      tripEndDate: _readDate(json['tripEndDate']),
      title: _readString(json['title'], 'title'),
      category: _readNullableString(json['category']) ?? '공유 여행',
      scheduledDate: _readRequiredDate(json['scheduledDate'], 'scheduledDate'),
      scheduledTime: _readNullableString(json['scheduledTime']),
      placeName: _readNullableString(json['placeName']),
      url: _readNullableString(json['url']),
      description: _readNullableString(json['description']),
      sortOrder: _readInt(json['sortOrder'] ?? 0, 'sortOrder'),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'category': category,
      'scheduledDate': _formatDate(scheduledDate),
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
      if (placeName != null) 'placeName': placeName,
      if (url != null) 'url': url,
      if (description != null) 'description': description,
      'sortOrder': sortOrder,
    };
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
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  static DateTime _readRequiredDate(Object? value, String fieldName) {
    final date = _readDate(value);

    if (date == null) {
      throw FormatException('$fieldName 값이 올바르지 않습니다.');
    }

    return date;
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
