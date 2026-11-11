import 'package:flutter/foundation.dart';

import '../../models/home_data.dart';
import '../../models/trip.dart';
import '../../models/trip_schedule.dart';
import '../../models/settlement.dart';
import '../../services/schedule_service.dart';
import '../../services/settlement_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    Future<List<Trip>> Function(String token)? tripLoader,
    Future<List<TripSchedule>> Function(String token, int tripId)?
    scheduleLoader,
    Future<List<SettlementData>> Function(String token)? settlementLoader,
    DateTime Function()? clock,
  }) : _tripLoader =
           tripLoader ??
           ((token) => ScheduleService.fetchTrips(accessToken: token)),
       _scheduleLoader =
           scheduleLoader ??
           ((token, id) => ScheduleService.fetchTripSchedules(
             accessToken: token,
             tripId: id,
           )),
       _settlementLoader =
           settlementLoader ??
           ((token) =>
               SettlementService.fetchParticipatingTrips(accessToken: token)),
       _clock = clock ?? DateTime.now;

  final Future<List<Trip>> Function(String token) _tripLoader;
  final Future<List<TripSchedule>> Function(String token, int tripId)
  _scheduleLoader;
  final Future<List<SettlementData>> Function(String token) _settlementLoader;
  final DateTime Function() _clock;
  String? _token;
  int? _userId;
  bool _disposed = false;
  Future<HomeData>? homeFuture;

  void updateSession({
    required bool isInitialized,
    required String? accessToken,
    required int? userId,
  }) {
    if (_disposed || !isInitialized) return;
    if (_token == accessToken && _userId == userId && homeFuture != null) {
      return;
    }
    _token = accessToken;
    _userId = userId;
    homeFuture = accessToken == null ? null : _load(accessToken, userId);
  }

  Future<HomeData> _load(String token, int? userId) async {
    final warnings = <String>[];
    // Start independent requests together and retain available sections on failure.
    final settlementsFuture = (() async {
      try {
        return await _settlementLoader(token)
            .timeout(const Duration(seconds: 20));
      } catch (_) {
        warnings.add('정산·동행 정보를 불러오지 못했어요.');
        return null;
      }
    })();
    final trips = await _tripLoader(token).timeout(const Duration(seconds: 20));
    List<TripSchedule>? schedules;
    try {
      final groups = await Future.wait(
        trips.map(
          (t) =>
              _scheduleLoader(token, t.id).timeout(const Duration(seconds: 20)),
        ),
      );
      schedules = groups.expand((s) => s).toList()
        ..sort(HomeData.compareSchedules);
    } catch (_) {
      warnings.add('일정을 불러오지 못했어요.');
    }
    final settlements = await settlementsFuture;
    final ids = trips.map((t) => t.id).toSet();
    return HomeData(
      trips: trips,
      schedules: schedules,
      settlements: settlements?.where((s) => ids.contains(s.tripId)).toList(),
      now: _clock(),
      currentUserId: userId,
      warnings: warnings,
    );
  }

  Future<void> reload() async {
    if (_disposed || _token == null) return;
    homeFuture = _load(_token!, _userId);
    notifyListeners();
    try {
      await homeFuture;
    } catch (_) {
      /* Render the error in the screen. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
