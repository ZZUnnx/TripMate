class TripSchedule {
  // Keep inferred positions separate from legacy/manual ordinal values.
  static const inferredOrderBase = 100000;

  /// Unknown times use a display position, without inventing a scheduled time.
  static int compareChronologically(TripSchedule left, TripSchedule right) {
    final leftDay = DateTime(
      left.scheduledDate.year,
      left.scheduledDate.month,
      left.scheduledDate.day,
    );
    final rightDay = DateTime(
      right.scheduledDate.year,
      right.scheduledDate.month,
      right.scheduledDate.day,
    );
    final dateCompare = leftDay.compareTo(rightDay);
    if (dateCompare != 0) return dateCompare;
    final positionCompare = _displayPosition(left)
        .compareTo(_displayPosition(right));
    if (positionCompare != 0) return positionCompare;
    final orderCompare = left.sortOrder.compareTo(right.sortOrder);
    return orderCompare != 0 ? orderCompare : left.id.compareTo(right.id);
  }

  static double _displayPosition(TripSchedule schedule) {
    final parts = schedule.scheduledTime?.split(':');
    if (parts != null && parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      final second = parts.length > 2 ? double.tryParse(parts[2]) ?? 0 : 0;
      if (hour != null &&
          hour >= 0 &&
          hour < 24 &&
          minute != null &&
          minute >= 0 &&
          minute < 60) {
        return hour * 60 + minute + 1 + second / 60;
      }
    }
    final inferredPosition = schedule.sortOrder - inferredOrderBase;
    return inferredPosition >= 1 && inferredPosition <= 1440
        ? inferredPosition.toDouble()
        : 1442;
  }

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
