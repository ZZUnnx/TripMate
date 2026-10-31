import '../../../models/trip.dart';
import '../../../models/trip_schedule.dart';
import 'calendar_transformations.dart';
import 'calendar_view_data.dart';

class CalendarData {
  CalendarData({required this.trips, required this.schedules})
    : agendaItems = schedules.map(calendarAgendaItemFromSchedule).toList();

  CalendarData.empty()
    : trips = const [],
      schedules = const [],
      agendaItems = const [];

  final List<Trip> trips;
  final List<TripSchedule> schedules;
  final List<CalendarAgendaItem> agendaItems;
}
