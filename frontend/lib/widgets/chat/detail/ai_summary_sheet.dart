import 'package:flutter/material.dart';

import '../../../controllers/chat/ai_summary_controller.dart';
import '../../common/responsive.dart';

class AiSummarySheet extends StatefulWidget {
  const AiSummarySheet({super.key, required this.controller});

  final AiSummaryController controller;

  @override
  State<AiSummarySheet> createState() => _AiSummarySheetState();
}

class _AiSummarySheetState extends State<AiSummarySheet> {
  AiSummaryController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChanged);
    controller.initialize();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    super.dispose();
  }

  Future<void> _saveSchedules() async {
    final result = await controller.saveSchedules();
    if (!mounted || result == null) return;
    if (result.error == null && result.remainingCount == 0) {
      Navigator.pop(context, result.savedCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.items;
    final schedules = items
        .where((item) => item['type'] == 'SCHEDULE')
        .toList();

    final reservations = items
        .where((item) => item['type'] == 'RESERVATION')
        .toList();

    final settlements = items
        .where((item) => item['type'] == 'SETTLEMENT')
        .toList();

    return PopScope(
      canPop: !controller.isSaving,
      child: SafeArea(
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
                  _SheetCloseButton(
                    onPressed: controller.isSaving
                        ? null
                        : () => Navigator.pop(context),
                  ),
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
                            _SummaryHeader(count: items.length),
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
                            if (controller.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            if (controller.loadError != null) ...[
                              const Text('기존 일정을 확인하지 못했어요. 다시 조회해 주세요.'),
                              TextButton(
                                onPressed: controller.initialize,
                                child: const Text('다시 조회'),
                              ),
                            ],
                            if (controller.isReady) ...[
                              for (var i = 0; i < items.length; i++)
                                if (controller.isReviewable(i))
                                  Material(
                                    color: Colors.transparent,
                                    child: CheckboxListTile(
                                      key: ValueKey('schedule-choice-$i'),
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(items[i]['title'].toString()),
                                      subtitle: Text(
                                        [
                                          items[i]['date'],
                                          items[i]['time'],
                                          items[i]['placeName'],
                                          if (controller.isExisting(i))
                                            '추가됨'
                                          else if (controller.isUpdate(i))
                                            '기존 일정 업데이트 · 확인 후 선택\n${controller.updatePreview(i)}'
                                          else if (controller.isSuspected(i))
                                            '중복 의심 · 확인 후 선택'
                                          else
                                            '새 일정',
                                        ].whereType<String>().join(' · '),
                                      ),
                                      value: controller.isSelected(i),
                                      onChanged:
                                          controller.isSaving ||
                                              controller.isExisting(i)
                                          ? null
                                          : (value) => controller.select(
                                              i,
                                              value ?? false,
                                            ),
                                    ),
                                  ),
                              if (controller.hasReviewableChanges)
                                Text(
                                  '선택 ${controller.pendingCount}개 · 기존 일정 ${controller.existingCount}개 제외',
                                )
                              else
                                const Text('추가하거나 업데이트할 일정이 없어요.'),
                            ],
                            const ResponsiveGap(height: 8),
                            Text(
                              '검토 대상 일정·예약 ${controller.eligibleCount}개. '
                              '정산 정보는 캘린더에 추가하지 않습니다.',
                              style: TextStyle(fontSize: context.rs(11)),
                            ),
                            if (controller.skippedCount > 0)
                              Text(
                                '날짜·제목·시간을 확인할 수 없는 ${controller.skippedCount}개는 제외됩니다.',
                                style: TextStyle(fontSize: context.rs(11)),
                              ),
                            if (controller.lastResult?.error != null) ...[
                              const ResponsiveGap(height: 8),
                              Text(
                                '${controller.savedCount}개 저장됨 · 남은 ${controller.pendingCount}개를 다시 시도해 주세요.\n'
                                '${controller.lastResult!.error}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: context.rs(11),
                                ),
                              ),
                            ],
                            const ResponsiveGap(height: 8),
                            if (controller.isSaving ||
                                (controller.isReady &&
                                    controller.hasReviewableChanges))
                              _SummaryPrimaryButton(
                                isSaving: controller.isSaving,
                                isRetry: controller.savedCount > 0,
                                onTap:
                                    controller.isSaving ||
                                        !controller.isReady ||
                                        controller.pendingCount == 0
                                    ? null
                                    : _saveSchedules,
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
          final amount = item['amount'];
          final peopleCount = item['peopleCount'];
          final lines = <String>[];

          if (startDate != null && endDate != null) {
            lines.add('$title · $startDate - $endDate');
          } else if (startDate != null) {
            lines.add('$title · $startDate');
          } else {
            lines.add(title);
          }

          final details = <String>[];
          if (amount != null) {
            details.add('총 ${_formatAmount(amount)}원');
          }
          if (peopleCount != null) {
            details.add('$peopleCount명');
          }
          if (details.isNotEmpty) {
            lines.add(details.join(' · '));
          }

          return lines.join('\n');
        })
        .join('\n\n');
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

  final VoidCallback? onPressed;

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
  const _SummaryHeader({required this.count});

  final int count;

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
                '$count개 정보를 찾았어요',
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
              '내용을 확인한 뒤 직접 추가해 주세요. 예약은 시작일에 표시되며 종료일은 메모에 저장됩니다.',
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
  const _SummaryPrimaryButton({
    required this.onTap,
    required this.isSaving,
    required this.isRetry,
  });

  final VoidCallback? onTap;
  final bool isSaving;
  final bool isRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null && !isSaving
          ? const Color(0xFF8A9895)
          : const Color(0xFF148776),
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
                isSaving
                    ? '저장 중...'
                    : (isRetry ? '남은 변경 다시 적용' : '선택한 일정 추가·업데이트'),
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
