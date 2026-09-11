import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';

// 캘린더 + 여행 카드 영역
class ScheduleOverview extends StatelessWidget {
  const ScheduleOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(flex: 6, child: _TripCalendar()),
        ResponsiveGap(width: 10),
        Expanded(flex: 5, child: TripSummaryCard()),
      ],
    );
  }
}

// 캘린더
class _TripCalendar extends StatefulWidget {
  const _TripCalendar();

  @override
  State<_TripCalendar> createState() => _TripCalendarState();
}

class _TripCalendarState extends State<_TripCalendar> {
  DateTime _focusedDay = DateTime.utc(2026, 9);
  DateTime _selectedDay = DateTime.utc(2026, 9, 13);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(208),
      padding: context.insetsFromLTRB(10, 8, 10, 10),
      decoration: cardDecoration(context),
      child: TableCalendar<void>(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.horizontalSwipe,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        rowHeight: context.rs(20),
        daysOfWeekHeight: context.rs(18),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: EdgeInsets.zero,
          leftChevronMargin: EdgeInsets.zero,
          rightChevronMargin: EdgeInsets.zero,
          leftChevronPadding: EdgeInsets.zero,
          rightChevronPadding: EdgeInsets.zero,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: const Color(0xFF737A90),
            size: context.rs(22),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF737A90),
            size: context.rs(22),
          ),
          titleTextStyle: TextStyle(
            color: const Color(0xFF121827),
            fontSize: context.rs(13),
            fontWeight: FontWeight.w800,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: const Color(0xFF8990A5),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
          weekendStyle: TextStyle(
            color: const Color(0xFFB0B6C6),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(context.rs(1)),
          defaultTextStyle: TextStyle(
            color: const Color(0xFF737A90),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
          weekendTextStyle: TextStyle(
            color: const Color(0xFF9AA1B3),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: const BoxDecoration(
            color: Color(0xFFEAE7FF),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: const Color(0xFF635BFF),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w800,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF635BFF),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.white,
            fontSize: context.rs(10),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// 여행 요약 카드
class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({
    this.status = '진행 예정',
    this.tripName = '제주도 여행',
    this.daysLeft = 'D-3',
    this.dateRange = '9/12 (목) - 9/15 (일)',
    this.participants = '참여자 4명',
    this.scheduleStatus = '일정 6개 확정',
    super.key,
  });

  final String status;
  final String tripName;
  final String daysLeft;
  final String dateRange;
  final String participants;
  final String scheduleStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(208),
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const _TripCoverImage(),
              Positioned(
                right: context.rs(10),
                top: context.rs(9),
                child: Container(
                  padding: context.symmetricInsets(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xEEF1EEFF),
                    borderRadius: BorderRadius.circular(context.rs(18)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x18000000),
                        blurRadius: context.rs(8),
                        offset: Offset(0, context.rs(3)),
                      ),
                    ],
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: const Color(0xFF635BFF),
                      fontSize: context.rs(7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: context.insetsFromLTRB(12, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      color: const Color(0xFF121827),
                      fontSize: context.rs(13),
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(text: '$tripName '),
                      TextSpan(
                        text: daysLeft,
                        style: const TextStyle(color: Color(0xFF635BFF)),
                      ),
                    ],
                  ),
                ),
                const ResponsiveGap(height: 9),
                _TripInfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: dateRange,
                ),
                const ResponsiveGap(height: 8),
                _ParticipantsRow(text: participants),
                const ResponsiveGap(height: 8),
                _TripInfoRow(
                  icon: Icons.assignment_outlined,
                  text: scheduleStatus,
                  textColor: const Color(0xFF46A96B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCoverImage extends StatelessWidget {
  const _TripCoverImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(82),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB8C9FF), Color(0xFFA9D3F3), Color(0xFF8FC8C6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: context.rs(16),
            child: Container(
              height: context.rs(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBFE7F2), Color(0xFF5FA6BD)],
                ),
              ),
            ),
          ),
          Positioned(
            left: context.rs(28),
            right: context.rs(30),
            bottom: context.rs(18),
            child: Container(
              height: context.rs(34),
              decoration: BoxDecoration(
                color: const Color(0xFF4E714F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.rs(40)),
                  topRight: Radius.circular(context.rs(16)),
                ),
              ),
            ),
          ),
          Positioned(
            left: context.rs(6),
            right: context.rs(64),
            bottom: context.rs(10),
            child: Container(
              height: context.rs(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF9F8),
                borderRadius: BorderRadius.circular(context.rs(24)),
              ),
            ),
          ),
          Positioned(
            left: context.rs(18),
            bottom: context.rs(24),
            child: Container(
              width: context.rs(46),
              height: context.rs(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3D6045),
                borderRadius: BorderRadius.circular(context.rs(20)),
              ),
            ),
          ),
          Positioned(
            right: context.rs(26),
            top: context.rs(12),
            child: Container(
              width: context.rs(34),
              height: context.rs(10),
              decoration: BoxDecoration(
                color: const Color(0xDDFFFFFF),
                borderRadius: BorderRadius.circular(context.rs(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.icon,
    required this.text,
    this.textColor = const Color(0xFF697087),
  });

  final IconData icon;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C83A0), size: context.rs(16)),
        const ResponsiveGap(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: context.rs(10),
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantsRow extends StatelessWidget {
  const _ParticipantsRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.group_outlined,
          color: const Color(0xFF7C83A0),
          size: context.rs(16),
        ),
        const ResponsiveGap(width: 8),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF697087),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const ResponsiveGap(width: 6),
        const _AvatarStack(),
        const Spacer(),
        const ResponsiveIcon(
          Icons.chevron_right_rounded,
          color: Color(0xFF8990A5),
          size: 20,
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  static const List<Color> _colors = [
    Color(0xFFDCC4A4),
    Color(0xFF445267),
    Color(0xFFF0D7B6),
    Color(0xFF232B33),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.rs(48),
      height: context.rs(22),
      child: Stack(
        children: [
          for (var index = 0; index < _colors.length; index++)
            Positioned(
              left: context.rs(index * 12),
              child: Container(
                width: context.rs(22),
                height: context.rs(22),
                decoration: BoxDecoration(
                  color: _colors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: context.rs(1.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
