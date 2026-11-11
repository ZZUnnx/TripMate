import 'settlement.dart';
import 'trip.dart';
import 'trip_schedule.dart';

class HomeData {
  HomeData({
    required this.trips,
    required this.schedules,
    required this.settlements,
    required this.now,
    required this.currentUserId,
    this.warnings = const [],
  });

  final List<Trip> trips;
  final List<TripSchedule>? schedules;
  final List<SettlementData>? settlements;
  final DateTime now;
  final int? currentUserId;
  final List<String> warnings;
  DateTime get today => DateTime(now.year, now.month, now.day);

  List<Trip> get upcomingTrips =>
      trips.where((trip) {
        final end = trip.endDate ?? trip.startDate;
        return end == null || !end.isBefore(today);
      }).toList()..sort((a, b) {
        if (a.startDate == null) {
          return b.startDate == null ? a.id.compareTo(b.id) : 1;
        }
        if (b.startDate == null) return -1;
        final order = a.startDate!.compareTo(b.startDate!);
        return order == 0 ? a.id.compareTo(b.id) : order;
      });

  Trip? get activeTrip => upcomingTrips.firstOrNull;
  SettlementData? settlementFor(int tripId) =>
      settlements?.where((s) => s.tripId == tripId).firstOrNull;
  List<TripSchedule>? schedulesFor(int tripId) =>
      schedules?.where((s) => s.tripId == tripId).toList();
  int? get companionCount => settlements
      ?.expand((s) => s.members)
      .map((m) => m.userId)
      .where((id) => id != currentUserId)
      .toSet()
      .length;
  int? get totalAmount =>
      settlements?.fold<int>(0, (sum, s) => sum + s.totalAmount);
  int? get expenseCount =>
      settlements?.fold<int>(0, (sum, s) => sum + s.expenseCount);
  List<SettlementData>? get needsAttention =>
      settlements?.where((s) => !s.completed && s.expenseCount > 0).toList();

  static int compareSchedules(TripSchedule a, TripSchedule b) {
    final date = a.scheduledDate.compareTo(b.scheduledDate);
    if (date != 0) return date;
    final time = (a.scheduledTime ?? '23:59:59').compareTo(
      b.scheduledTime ?? '23:59:59',
    );
    if (time != 0) return time;
    final order = a.sortOrder.compareTo(b.sortOrder);
    return order != 0 ? order : a.id.compareTo(b.id);
  }

  List<TripSchedule>? get monthlySchedules =>
      schedules
          ?.where(
            (s) =>
                s.scheduledDate.year == now.year &&
                s.scheduledDate.month == now.month,
          )
          .toList()
        ?..sort(compareSchedules);

  TripSchedule? get nextSchedule {
    final candidates = schedules?.where((s) {
      if (s.scheduledDate.isBefore(today)) return false;
      if (s.scheduledTime == null) return true;
      final parts = s.scheduledTime!.split(':');
      final time = DateTime(
        s.scheduledDate.year,
        s.scheduledDate.month,
        s.scheduledDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
      return !time.isBefore(now);
    }).toList()?..sort(compareSchedules);
    return candidates?.firstOrNull;
  }
}

String homeDate(DateTime date) => '${date.year}.${date.month}.${date.day}';
String homeTripPeriod(Trip trip) => trip.startDate == null
    ? '여행 기간 미정'
    : '${homeDate(trip.startDate!)}${trip.endDate == null || trip.endDate == trip.startDate ? '' : ' – ${homeDate(trip.endDate!)}'}';
String homeTripStatus(Trip trip, DateTime now) {
  if (trip.startDate == null) return '날짜 미정';
  final days = DateTime.utc(
    trip.startDate!.year,
    trip.startDate!.month,
    trip.startDate!.day,
  ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  return days > 0
      ? 'D-$days'
      : days == 0
      ? '오늘 출발'
      : '여행 중';
}
