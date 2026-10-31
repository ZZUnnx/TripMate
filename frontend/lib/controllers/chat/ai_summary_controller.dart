import 'package:flutter/foundation.dart';

import '../../services/schedule_service.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

class AiSummarySaveResult {
  const AiSummarySaveResult({
    required this.savedCount,
    required this.remainingCount,
    this.error,
  });

  final int savedCount;
  final int remainingCount;
  final Object? error;
}

class AiSummaryController extends ChangeNotifier {
  AiSummaryController({
    required List<dynamic> items,
    required int tripId,
    required String accessToken,
    Future<void> Function(CalendarScheduleDraft draft)? scheduleCreator,
  }) : items = List.unmodifiable(
         items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
       ),
       _scheduleCreator =
           scheduleCreator ??
           ((draft) async {
             await ScheduleService.createScheduleFromInput(
               accessToken: accessToken,
               tripId: draft.tripId,
               title: draft.title,
               category: draft.category,
               scheduledDate: draft.scheduledDate,
               scheduledTime: draft.scheduledTime,
               placeName: draft.placeName,
               url: draft.url,
               description: draft.description,
             );
           }) {
    for (var i = 0; i < this.items.length; i++) {
      final draft = _toDraft(this.items[i], tripId);
      if (draft != null) _drafts[i] = draft;
    }
  }

  final List<Map<String, dynamic>> items;
  final Future<void> Function(CalendarScheduleDraft draft) _scheduleCreator;
  final _drafts = <int, CalendarScheduleDraft>{};
  final _savedIndices = <int>{};
  bool _isSaving = false;
  bool _disposed = false;
  AiSummarySaveResult? _lastResult;

  bool get isSaving => _isSaving;
  int get eligibleCount => _drafts.length;
  int get savedCount => _savedIndices.length;
  int get pendingCount => eligibleCount - savedCount;
  int get skippedCount => items.where(_isCalendarItem).length - eligibleCount;
  AiSummarySaveResult? get lastResult => _lastResult;

  Future<AiSummarySaveResult?> saveSchedules() async {
    if (_disposed || _isSaving || pendingCount == 0) return null;
    _isSaving = true;
    _lastResult = null;
    notifyListeners();
    Object? error;
    try {
      for (final entry in _drafts.entries) {
        if (_disposed) break;
        if (_savedIndices.contains(entry.key)) continue;
        try {
          await _scheduleCreator(entry.value);
          _savedIndices.add(entry.key);
        } catch (e) {
          error = e;
          break;
        }
      }
      final result = AiSummarySaveResult(
        savedCount: savedCount,
        remainingCount: pendingCount,
        error: error,
      );
      _lastResult = result;
      return result;
    } finally {
      _isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  static bool _isCalendarItem(Map<String, dynamic> item) =>
      item['type'] == 'SCHEDULE' || item['type'] == 'RESERVATION';

  static CalendarScheduleDraft? _toDraft(
    Map<String, dynamic> item,
    int tripId,
  ) {
    if (!_isCalendarItem(item)) return null;
    final title = _text(item['title']);
    final date = _date(item['date']);
    if (title == null || date == null) return null;
    final time = _text(item['time']);
    if (time != null &&
        !RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$').hasMatch(time)) {
      return null;
    }
    final isReservation = item['type'] == 'RESERVATION';
    final description = <String>[?_text(item['description'])];
    if (isReservation && _text(item['endDate']) != null) {
      final endDate = _date(item['endDate']);
      if (endDate == null || endDate.isBefore(date)) return null;
      description.add('예약 종료일: ${_text(item['endDate'])}');
    }
    return CalendarScheduleDraft(
      tripId: tripId,
      title: title,
      category: isReservation ? '예약' : '공유 여행',
      scheduledDate: date,
      scheduledTime: time == null
          ? null
          : (time.length == 5 ? '$time:00' : time),
      placeName: _text(item['placeName']),
      url: _text(item['url']),
      description: description.isEmpty ? null : description.join('\n'),
    );
  }

  static String? _text(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  static DateTime? _date(Object? value) {
    final text = _text(value);
    if (text == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return null;
    }
    final date = DateTime.tryParse(text);
    if (date == null ||
        date.year < 1 ||
        date.toIso8601String().substring(0, 10) != text) {
      return null;
    }
    return date;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
