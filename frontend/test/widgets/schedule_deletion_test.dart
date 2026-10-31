import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/widgets/calendar/confirm_schedule_deletion.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_transformations.dart';
import 'package:frontend/widgets/calendar/selected_day_agenda.dart';
import 'package:frontend/widgets/calendar/detail/trip_timeline.dart';
import 'package:frontend/widgets/common/swipe_delete_action.dart';

void main() {
  final schedule = TripSchedule(
    id: 1,
    tripId: 7,
    tripTitle: 'trip',
    title: 'tour',
    scheduledDate: DateTime(2026, 10, 31),
    category: 'shared',
    sortOrder: 0,
  );

  testWidgets(
    'agenda deletion requires confirmation and cancellation keeps it',
    (tester) async {
      var deletes = 0;
      var navigations = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => SelectedDayAgenda(
                selectedDay: schedule.scheduledDate,
                agendaItems: [calendarAgendaItemFromSchedule(schedule)],
                onAgendaTap: (_) => navigations++,
                onDeleteAgenda: (agenda) async {
                  if (await confirmScheduleDeletion(context, agenda.title)) {
                    deletes++;
                  }
                },
              ),
            ),
          ),
        ),
      );
      expect(find.byTooltip('일정 삭제'), findsNothing);
      await tester.drag(find.byType(SwipeDeleteAction), const Offset(-180, 0));
      await tester.pumpAndSettle();
      expect(deletes, 0);
      await tester.tap(find.byTooltip('일정 삭제'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(deletes, 0);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(deletes, 0);
      await tester.drag(find.byType(SwipeDeleteAction), const Offset(-180, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('일정 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();
      expect(deletes, 1);
      expect(navigations, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('agenda prevents another deletion while a request is running', (
    tester,
  ) async {
    var deletes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDayAgenda(
            selectedDay: schedule.scheduledDate,
            agendaItems: [calendarAgendaItemFromSchedule(schedule)],
            deletingIds: {schedule.id},
            onAgendaTap: (_) {},
            onDeleteAgenda: (_) => deletes++,
          ),
        ),
      ),
    );
    await tester.drag(find.byType(SwipeDeleteAction), const Offset(-180, 0));
    await tester.pump();
    expect(deletes, 0);
    expect(find.byTooltip('일정 삭제'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full swipe only reveals the action and right swipe closes it', (
    tester,
  ) async {
    var deletes = 0;
    var navigations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDayAgenda(
            selectedDay: schedule.scheduledDate,
            agendaItems: [calendarAgendaItemFromSchedule(schedule)],
            onAgendaTap: (_) => navigations++,
            onDeleteAgenda: (_) => deletes++,
          ),
        ),
      ),
    );
    await tester.drag(find.byType(SwipeDeleteAction), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('일정 삭제'), findsOneWidget);
    expect(deletes, 0);
    await tester.drag(find.byType(SwipeDeleteAction), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('일정 삭제'), findsNothing);
    await tester.tap(find.text('tour'));
    await tester.pump();
    expect(navigations, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timeline preserves expansion and reveals deletion on swipe', (
    tester,
  ) async {
    int? deletedId;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TripTimeline(
              sections: calendarTimelineSectionsFromSchedules([schedule]),
              onDelete: (item) => deletedId = item.id,
            ),
          ),
        ),
      ),
    );
    expect(find.byTooltip('일정 삭제'), findsNothing);
    await tester.tap(find.text('tour'));
    await tester.pumpAndSettle();
    expect(find.text('날짜'), findsOneWidget);
    await tester.drag(find.byType(SwipeDeleteAction), const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('일정 삭제'));
    await tester.pumpAndSettle();
    expect(deletedId, schedule.id);
    expect(find.text('날짜'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
