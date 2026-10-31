import 'package:flutter/foundation.dart';

import '../../models/settlement.dart';
import '../../services/settlement_service.dart';

class SettlementDetailController extends ChangeNotifier {
  SettlementDetailController({
    required this.tripId,
    required this.accessToken,
    Future<SettlementData> Function()? detailLoader,
    Future<void> Function(ExpenseDraft draft, int? expenseId)? expenseSaver,
    Future<void> Function(int id)? expenseDeleter,
    Future<void> Function(bool completed)? completionSaver,
  }) : _loader =
           detailLoader ??
           (() => SettlementService.fetchDetail(accessToken, tripId)),
       _saver =
           expenseSaver ??
           ((draft, id) => SettlementService.saveExpense(
             accessToken,
             tripId,
             draft,
             expenseId: id,
           )),
       _deleter =
           expenseDeleter ??
           ((id) => SettlementService.deleteExpense(accessToken, id)),
       _completionSaver =
           completionSaver ??
           ((completed) =>
               SettlementService.setCompleted(accessToken, tripId, completed));

  final int tripId;
  final String accessToken;
  final Future<SettlementData> Function() _loader;
  final Future<void> Function(ExpenseDraft, int?) _saver;
  final Future<void> Function(int) _deleter;
  final Future<void> Function(bool) _completionSaver;
  SettlementData? data;
  Object? error;
  bool isLoading = false;
  bool isBusy = false;
  bool _disposed = false;
  int _loadVersion = 0;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_loadVersion;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _loader();
      if (!_disposed && version == _loadVersion) data = result;
    } catch (e) {
      if (!_disposed && version == _loadVersion) error = e;
    } finally {
      if (!_disposed && version == _loadVersion) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    if (_disposed || isBusy) return false;
    isBusy = true;
    notifyListeners();
    try {
      await action();
      if (!_disposed) await load();
      return true;
    } finally {
      isBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> saveExpense(ExpenseDraft draft, {int? expenseId}) =>
      _mutate(() => _saver(draft, expenseId));
  Future<bool> deleteExpense(int id) => _mutate(() => _deleter(id));
  Future<bool> setCompleted(bool completed) =>
      _mutate(() => _completionSaver(completed));
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
