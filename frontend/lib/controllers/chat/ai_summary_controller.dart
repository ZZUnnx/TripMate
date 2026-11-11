import 'package:flutter/foundation.dart';

import '../../services/schedule_service.dart';
import '../../models/trip_schedule.dart';
import '../../models/settlement.dart';
import '../../services/settlement_service.dart';
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
    Future<SettlementData> Function()? settlementLoader,
    Future<void> Function(ExpenseDraft draft)? expenseCreator,
  }) : items = List.unmodifiable(
         items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
       ),
       _settlementLoader =
           settlementLoader ??
           (() => SettlementService.fetchDetail(accessToken, tripId)),
       _expenseCreator =
           expenseCreator ??
           ((draft) =>
               SettlementService.saveExpense(accessToken, tripId, draft)),
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
  final Future<bool> Function(CalendarScheduleDraft draft) _scheduleCreator;
  final Future<List<TripSchedule>> Function() _scheduleLoader;
  final Future<SettlementData> Function() _settlementLoader;
  final Future<void> Function(ExpenseDraft draft) _expenseCreator;
  final _expenses = <int, ExpenseDraft>{};
  final _savedExpenses = <int>{};
  final _existingExpenses = <int>{};
  int get savedExpenseCount => _savedExpenses.length;
  int get existingExpenseCount => _existingExpenses.length;
  int get pendingExpenseCount =>
      _expenses.keys.where((i) => !isExpenseExisting(i)).length;
  bool isExpenseCandidate(int index) =>
      items[index]['type'] == 'SETTLEMENT' ||
      (items[index]['type'] == 'RESERVATION' && items[index]['amount'] != null);
  bool get hasExpenses =>
      List.generate(items.length, (i) => i).any(isExpenseCandidate);
  bool isExpenseExisting(int index) =>
      _savedExpenses.contains(index) || _existingExpenses.contains(index);
  ExpenseDraft? expenseDraft(int index) => _expenses[index];
  Future<SettlementData> loadSettlement() => _settlementLoader();

  void confirmExpense(int index, ExpenseDraft draft) {
    if (_disposed ||
        _isSaving ||
        !isExpenseCandidate(index) ||
        isExpenseExisting(index)) {
      return;
    }
    _expenses[index] = draft;
    notifyListeners();
  }

  void removeExpense(int index) {
    if (_disposed || _isSaving || isExpenseExisting(index)) return;
    _expenses.remove(index);
    notifyListeners();
  }

  static bool _sameExpense(ExpenseDraft a, ExpenseDraft b) =>
      _normalized(a.title) == _normalized(b.title) &&
      a.amount == b.amount &&
      a.payerId == b.payerId &&
      a.date.year == b.date.year &&
      a.date.month == b.date.month &&
      a.date.day == b.date.day &&
      _normalized(a.placeName) == _normalized(b.placeName) &&
      setEquals(a.participantIds.toSet(), b.participantIds.toSet());
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
  int get savedCount => _savedIndices.length + savedExpenseCount;
  int get pendingCount => _selectedIndices.length + pendingExpenseCount;
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
      if (error == null && pendingExpenseCount > 0 && !_disposed) {
        try {
          // Recheck before each batch, including retries after a lost response.
          final data = await _settlementLoader();
          final known = data.expenses
              .map(
                (e) => ExpenseDraft(
                  title: e.title,
                  amount: e.amount,
                  payerId: e.payerId,
                  date: e.date,
                  participantIds: e.participantIds,
                  placeName: e.placeName,
                ),
              )
              .toList();
          for (final entry in _expenses.entries) {
            if (_disposed) break;
            if (isExpenseExisting(entry.key)) continue;
            if (known.any((e) => _sameExpense(e, entry.value))) {
              _existingExpenses.add(entry.key);
              continue;
            }
            await _expenseCreator(entry.value);
            _savedExpenses.add(entry.key);
            known.add(entry.value);
          }
        } catch (e) {
          error = e;
        }
      }
      final result = AiSummarySaveResult(
        savedCount: savedCount,
        existingCount: existingCount + existingExpenseCount,
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
