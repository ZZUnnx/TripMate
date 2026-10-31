import 'package:flutter/foundation.dart';

import '../../models/settlement.dart';
import '../../services/settlement_service.dart';

class SettlementListController extends ChangeNotifier {
  SettlementListController({
    Future<List<SettlementData>> Function(String token)? tripLoader,
  }) : _tripLoader =
           tripLoader ??
           ((token) =>
               SettlementService.fetchParticipatingTrips(accessToken: token));

  final Future<List<SettlementData>> Function(String token) _tripLoader;
  Future<List<SettlementData>>? _tripsFuture;
  String? _accessToken;
  bool _disposed = false;

  Future<List<SettlementData>>? get tripsFuture => _tripsFuture;

  void updateSession({
    required bool isInitialized,
    required String? accessToken,
  }) {
    if (_disposed || !isInitialized) return;
    if (_accessToken == accessToken && _tripsFuture != null) return;
    _accessToken = accessToken;
    _tripsFuture = accessToken == null ? null : _tripLoader(accessToken);
  }

  void reload() {
    final token = _accessToken;
    if (_disposed || token == null) return;
    _tripsFuture = _tripLoader(token);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
