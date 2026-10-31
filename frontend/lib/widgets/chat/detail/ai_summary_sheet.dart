import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class AiSummarySheet extends StatelessWidget {
  const AiSummarySheet({super.key, required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    final schedules = items
        .where((item) => item['type'] == 'SCHEDULE')
        .toList();

    final reservations = items
        .where((item) => item['type'] == 'RESERVATION')
        .toList();

    final settlements = items
        .where((item) => item['type'] == 'SETTLEMENT')
        .toList();

    return SafeArea(
      top: false,
      child: Container(
        height: context.rs(620),
        padding: context.insetsFromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(24)),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: context.rs(44),
              height: context.rs(4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE6E3),
                borderRadius: BorderRadius.circular(context.rs(999)),
              ),
            ),
            const ResponsiveGap(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 요약',
                        style: TextStyle(
                          color: const Color(0xFF152523),
                          fontSize: context.rs(18),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const ResponsiveGap(height: 2),
                      Text(
                        '현재까지 대화에서 찾은 정보를 검토하고 공유 일정에 추가해 주세요',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF60706D),
                          fontSize: context.rs(11),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _SheetCloseButton(onPressed: () => Navigator.pop(context)),
              ],
            ),
            const ResponsiveGap(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: context.symmetricInsets(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF9),
                        border: Border.all(color: const Color(0xFFCDEAE4)),
                        borderRadius: BorderRadius.circular(context.rs(12)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF18332E)
                                .withValues(alpha: 0.08),
                            blurRadius: context.rs(24),
                            offset: Offset(0, context.rs(8)),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const _SummaryHeader(),
                          const ResponsiveGap(height: 8),
                          if (schedules.isNotEmpty) ...[
                            _SummaryItem(
                              icon: Icons.calendar_month_outlined,
                              iconBackground: const Color(0xFFEAF0FB),
                              label: '일정',
                              value: _buildScheduleContent(schedules),
                            ),
                            const ResponsiveGap(height: 8),
                          ],
                          if (reservations.isNotEmpty) ...[
                            _SummaryItem(
                              icon: Icons.confirmation_num_outlined,
                              iconBackground: const Color(0xFFFFF6DF),
                              label: '예약',
                              value: _buildReservationContent(reservations),
                            ),
                            const ResponsiveGap(height: 8),
                          ],
                          if (settlements.isNotEmpty) ...[
                            _SummaryItem(
                              icon: Icons.account_balance_wallet_outlined,
                              iconBackground: const Color(0xFFEEF3F2),
                              label: '정산',
                              value: _buildSettlementContent(settlements),
                            ),
                            const ResponsiveGap(height: 8),
                          ],
                          if (items.isEmpty) ...[
                            const Text('대화에서 등록할 항목을 찾지 못했습니다.'),
                            const ResponsiveGap(height: 8),
                          ],
                          const ResponsiveGap(height: 8),
                          const _SummaryNotice(),
                          const ResponsiveGap(height: 8),
                          _SummaryPrimaryButton(
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const ResponsiveGap(height: 12),
                    _ReanalyzeButton(onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildScheduleContent(List<dynamic> schedules) {
    return schedules
        .map((item) {
          final date = _formatDate(item['date']);
          final time = item['time']?.toString();
          final title = item['title']?.toString() ?? '일정';

          final parts = <String>[];

          if (date != null) {
            parts.add(date);
          }

          if (time != null && time.isNotEmpty) {
            parts.add(time);
          }

          parts.add(title);

          return parts.join(' ');
        })
        .join('\n');
  }

  String _buildReservationContent(List<dynamic> reservations) {
    return reservations
        .map((item) {
          final title = item['title']?.toString() ?? '예약';

          final startDate = _formatDate(item['date']);
          final endDate = _formatDate(item['endDate']);

          if (startDate != null && endDate != null) {
            return '$title · $startDate - $endDate';
          }
          if (startDate != null) {
            return '$title · $startDate';
          }

          return title;
        })
        .join('\n');
  }

  String _buildSettlementContent(List<dynamic> settlements) {
    return settlements
        .map((item) {
          final title = item['title']?.toString() ?? '정산';

          final amount = item['amount'];
          final peopleCount = item['peopleCount'];

          final parts = <String>[title];

          if (amount != null) {
            parts.add('${_formatAmount(amount)}원');
          }

          if (peopleCount != null) {
            parts.add('$peopleCount명 분담');
          }

          return parts.join(' · ');
        })
        .join('\n');
  }

  String? _formatDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    return '${date.month}/${date.day}';
  }

  String _formatAmount(dynamic value) {
    final number = int.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: context.rs(34),
          height: context.rs(34),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDCE6E3)),
          ),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFF60706D),
            size: context.rs(13),
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.rs(30),
          height: context.rs(30),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3EE),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: const Color(0xFF0B5F55),
            size: context.rs(15),
          ),
        ),
        const ResponsiveGap(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '5개 정보를 찾았어요',
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '추가 전 내용을 확인해 주세요',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: context.symmetricInsets(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3EE),
            borderRadius: BorderRadius.circular(context.rs(999)),
          ),
          child: Text(
            'AI 후보',
            style: TextStyle(
              color: const Color(0xFF0B5F55),
              fontSize: context.rs(9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(30),
            height: context.rs(30),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(context.rs(8)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0B5F55),
              size: context.rs(15),
            ),
          ),
          const ResponsiveGap(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 5),
          _SummaryCircleAction(icon: Icons.edit_outlined, onTap: () {}),
          const ResponsiveGap(width: 5),
          _SummaryCircleAction(icon: Icons.close_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _SummaryCircleAction extends StatelessWidget {
  const _SummaryCircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(26),
          height: context.rs(26),
          child: Icon(
            icon,
            color: const Color(0xFF60706D),
            size: context.rs(13),
          ),
        ),
      ),
    );
  }
}

class _SummaryNotice extends StatelessWidget {
  const _SummaryNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF3EE),
        borderRadius: BorderRadius.circular(context.rs(8)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: const Color(0xFF0B5F55),
            size: context.rs(14),
          ),
          const ResponsiveGap(width: 7),
          Expanded(
            child: Text(
              'AI가 자동 확정하지 않아요. 수정하거나 제외한 뒤 직접 추가해 주세요.',
              style: TextStyle(
                color: const Color(0xFF0B5F55),
                fontSize: context.rs(9),
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPrimaryButton extends StatelessWidget {
  const _SummaryPrimaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: SizedBox(
          height: context.rs(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: context.rs(16),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '공유 일정에 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReanalyzeButton extends StatelessWidget {
  const _ReanalyzeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: Container(
          height: context.rs(40),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_tethering_rounded,
                color: const Color(0xFF60706D),
                size: context.rs(16),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '다시 분석하기',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
