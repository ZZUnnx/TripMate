import 'package:flutter/foundation.dart';

import '../../services/schedule_service.dart';
import '../../models/trip_schedule.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

class AiSummarySaveResult {
  const AiSummarySaveResult({
    required this.savedCount,
    required this.remainingCount,
    this.error,
    this.existingCount = 0,
  });

  final int savedCount;
  final int remainingCount;
  final Object? error;
  final int existingCount;
}

class AiSummaryController extends ChangeNotifier {
  AiSummaryController({
    required List<dynamic> items,
    required int tripId,
    required String accessToken,
    Future<void> Function(CalendarScheduleDraft draft)? scheduleCreator,
    Future<bool> Function(CalendarScheduleDraft draft)? scheduleImporter,
    Future<List<TripSchedule>> Function()? scheduleLoader,
    Future<void> Function(TripSchedule schedule)? scheduleUpdater,
  }) : items = List.unmodifiable(
         items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
       ),
       _scheduleUpdater =
           scheduleUpdater ??
           ((schedule) async {
             await ScheduleService.updateSchedule(
               accessToken: accessToken,
               schedule: schedule,
               aiUpdate: true,
             );
           }),
       _scheduleLoader =
           scheduleLoader ??
           (() => ScheduleService.fetchTripSchedules(
             accessToken: accessToken,
             tripId: tripId,
           )),
       _scheduleCreator =
           scheduleImporter ??
           (scheduleCreator == null
               ? ((draft) => ScheduleService.importSchedule(
                   accessToken: accessToken,
                   tripId: draft.tripId,
                   schedule: {
                     'title': draft.title,
                     'category': draft.category,
                     'scheduledDate': draft.scheduledDate
                         .toIso8601String()
                         .substring(0, 10),
                     'scheduledTime': draft.scheduledTime,
                     'placeName': draft.placeName,
                     'url': draft.url,
                     'description': draft.description,
                   },
                 ))
               : ((draft) async {
                   await scheduleCreator(draft);
                   return true;
                 })) {
    for (var i = 0; i < this.items.length; i++) {
      final draft = _toDraft(this.items[i], tripId);
      if (draft != null) _drafts[i] = draft;
    }
  }

  final List<Map<String, dynamic>> items;
  final Future<void> Function(TripSchedule schedule) _scheduleUpdater;
  final _updates = <int, TripSchedule>{};
  bool isUpdate(int index) => _updates.containsKey(index);
  String updatePreview(int index) {
    final old = _updates[index]!;
    final draft = _drafts[index]!;
    return '기존: ${old.scheduledDate.toIso8601String().substring(0, 10)} ${old.scheduledTime ?? "시간 미정"}\n'
        '${old.description ?? "메모 없음"}\n변경: ${draft.scheduledDate.toIso8601String().substring(0, 10)} ${draft.scheduledTime ?? old.scheduledTime ?? "시간 미정"}\n'
        '${_mergedDescription(old.description, draft.description) ?? "메모 없음"}';
  }

  static String? _mergedDescription(String? old, String? incoming) {
    final lines = (old ?? '')
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    for (final line
        in (incoming ?? '').split('\n').where((s) => s.trim().isNotEmpty)) {
      for (final prefix in ['예약 종료일:', '예약 비용:', '예약 인원:']) {
        if (line.startsWith(prefix)) {
          lines.removeWhere((s) => s.startsWith(prefix));
        }
      }
      if (!lines.contains(line)) lines.add(line);
    }
    return lines.isEmpty ? null : lines.join('\n');
  }

  static TripSchedule _merged(TripSchedule old, CalendarScheduleDraft draft) =>
      TripSchedule(
        id: old.id,
        tripId: old.tripId,
        tripTitle: old.tripTitle,
        title: old.title,
        category: old.category,
        scheduledDate: draft.scheduledDate,
        scheduledTime: draft.scheduledTime ?? old.scheduledTime,
        placeName: draft.placeName ?? old.placeName,
        url: draft.url ?? old.url,
        description: _mergedDescription(old.description, draft.description),
        sortOrder: old.sortOrder,
      );
  final Future<bool> Function(CalendarScheduleDraft draft) _scheduleCreator;
  final Future<List<TripSchedule>> Function() _scheduleLoader;
  final _existingIndices = <int>{};
  final _suspectedIndices = <int>{};
  final _selectedIndices = <int>{};
  bool _initialized = false;
  bool _isLoading = false;
  Object? loadError;
  bool get isLoading => _isLoading;
  bool get isReady => _initialized;
  int get existingCount => _existingIndices.length;
  bool isExisting(int index) =>
      _existingIndices.contains(index) || _savedIndices.contains(index);
  bool isSuspected(int index) => _suspectedIndices.contains(index);
  bool isEligible(int index) => _drafts.containsKey(index);
  bool isSelected(int index) => _selectedIndices.contains(index);

  void select(int index, bool selected) {
    if (_disposed ||
        !_initialized ||
        _isSaving ||
        isExisting(index) ||
        !isEligible(index)) {
      return;
    }
    selected ? _selectedIndices.add(index) : _selectedIndices.remove(index);
    notifyListeners();
  }

  static String _normalized(String? text) =>
      (text ?? '').replaceAll(RegExp(r'\s+', unicode: true), '');
  static String _time(String? time) =>
      time == null ? '' : (time.length == 5 ? '$time:00' : time);
  static bool _sameSlot(CalendarScheduleDraft a, CalendarScheduleDraft b) =>
      a.tripId == b.tripId &&
      (a.category == '예약') == (b.category == '예약') &&
      a.scheduledDate == b.scheduledDate &&
      _time(a.scheduledTime) == _time(b.scheduledTime) &&
      _normalized(a.placeName) == _normalized(b.placeName);
  static bool _same(CalendarScheduleDraft a, CalendarScheduleDraft b) =>
      _sameSlot(a, b) && _normalized(a.title) == _normalized(b.title);

  Future<void> initialize() async {
    if (_disposed || _isLoading || _initialized) return;
    _isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final schedules = await _scheduleLoader();
      if (_disposed) return;
      final known = schedules
          .map(
            (s) => CalendarScheduleDraft(
              tripId: s.tripId,
              title: s.title,
              category: s.category,
              scheduledDate: s.scheduledDate,
              scheduledTime: s.scheduledTime,
              placeName: s.placeName,
            ),
          )
          .toList();
      for (final entry in _drafts.entries) {
        final draft = entry.value;
        final matches = schedules
            .where(
              (s) =>
                  s.tripId == draft.tripId &&
                  (s.category == '예약') == (draft.category == '예약') &&
                  _normalized(s.title) == _normalized(draft.title) &&
                  (s.placeName == null ||
                      draft.placeName == null ||
                      _normalized(s.placeName) == _normalized(draft.placeName)),
            )
            .toList();
        final exactMatches = matches
            .where(
              (s) =>
                  s.scheduledDate == draft.scheduledDate &&
                  _time(s.scheduledTime) == _time(draft.scheduledTime),
            )
            .toList();
        final candidates = exactMatches.length == 1 ? exactMatches : matches;
        if (candidates.length == 1) {
          final old = candidates.single;
          final merged = _merged(old, draft);
          if (merged.scheduledDate != old.scheduledDate ||
              _time(merged.scheduledTime) != _time(old.scheduledTime) ||
              merged.placeName != old.placeName ||
              merged.url != old.url ||
              merged.description != old.description) {
            _updates[entry.key] = old;
            continue;
          }
          _existingIndices.add(entry.key);
          continue;
        } else if (matches.isNotEmpty) {
          _suspectedIndices.add(entry.key);
          continue;
        }
        if (known.any((s) => _same(entry.value, s))) {
          _existingIndices.add(entry.key);
        } else if (known.any((s) => _sameSlot(entry.value, s))) {
          _suspectedIndices.add(entry.key);
        } else {
          _selectedIndices.add(entry.key);
        }
      }
      _initialized = true;
    } catch (e) {
      loadError = e;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  final _drafts = <int, CalendarScheduleDraft>{};
  final _savedIndices = <int>{};
  bool _isSaving = false;
  bool _disposed = false;
  AiSummarySaveResult? _lastResult;

  bool get isSaving => _isSaving;
  int get eligibleCount => _drafts.length;
  int get savedCount => _savedIndices.length;
  int get pendingCount => _selectedIndices.length;
  int get skippedCount => items.where(_isCalendarItem).length - eligibleCount;
  AiSummarySaveResult? get lastResult => _lastResult;

  Future<AiSummarySaveResult?> saveSchedules() async {
    if (_disposed || _isSaving || !_initialized || pendingCount == 0) {
      return null;
    }
    _isSaving = true;
    _lastResult = null;
    notifyListeners();
    Object? error;
    try {
      for (final entry in _drafts.entries) {
        if (_disposed) break;
        if (!_selectedIndices.contains(entry.key)) continue;
        try {
          if (_updates.containsKey(entry.key)) {
            await _scheduleUpdater(_merged(_updates[entry.key]!, entry.value));
            _savedIndices.add(entry.key);
            _selectedIndices.remove(entry.key);
            continue;
          }
          final created = await _scheduleCreator(entry.value);
          if (created) {
            _savedIndices.add(entry.key);
          } else {
            _existingIndices.add(entry.key);
          }
          _selectedIndices.remove(entry.key);
          // Exclude identical candidates elsewhere in this same AI response.
          for (final other in _drafts.entries) {
            if (other.key != entry.key && _same(entry.value, other.value)) {
              _existingIndices.add(other.key);
              _selectedIndices.remove(other.key);
            }
          }
        } catch (e) {
          error = e;
          break;
        }
      }
      final result = AiSummarySaveResult(
        savedCount: savedCount,
        existingCount: existingCount,
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
    if (isReservation) {
      final amount = item['amount'];
      final peopleCount = item['peopleCount'];
      if (amount is int && amount >= 0) {
        description.add('예약 비용: $amount원');
      }
      if (peopleCount is int && peopleCount > 0) {
        description.add('예약 인원: $peopleCount명');
      }
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
