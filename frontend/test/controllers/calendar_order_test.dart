import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_transformations.dart';

void main() {
  TripSchedule item(int id, {String? time, int order = 0, int day = 16}) =>
      TripSchedule(
        id: id,
        tripId: 1,
        tripTitle: 'trip',
        title: 'item $id',
        scheduledDate: DateTime(2026, 12, day),
        category: '공유 여행',
        scheduledTime: time,
        sortOrder: order,
      );

  test('unknown times follow inferred activity order between actual times', () {
    final schedules = [
      item(4),
      item(3, time: '12:00'),
      item(2, order: TripSchedule.inferredOrderBase + 661),
      item(1, time: '10:00', order: TripSchedule.inferredOrderBase + 900),
      item(5, time: '08:00', day: 17),
    ];
    schedules.sort(calendarCompareTripSchedules);
    expect(schedules.map((s) => s.id), [1, 2, 3, 4, 5]);
    final sections = calendarTimelineSectionsFromSchedules(
      schedules.reversed.toList(),
    );
    expect(sections.first.items.map((s) => s.schedule.id), [1, 2, 3, 4]);
    expect(sections.first.items[1].time, '시간 미정');
    expect(schedules[1].scheduledTime, isNull);
  });

  test('legacy order stays at end and actual times include seconds', () {
    final schedules = [
      item(4, order: 2),
      item(2, time: '09:00:30'),
      item(3, order: 1),
      item(1, time: '09:00:00'),
    ];
    schedules.sort(TripSchedule.compareChronologically);
    expect(schedules.map((s) => s.id), [1, 2, 3, 4]);
  });
}
