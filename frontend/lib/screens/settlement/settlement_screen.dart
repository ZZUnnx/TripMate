import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/settlement/settlement_result_sheet.dart';

enum _SettlementView { overview, payer, place }

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({
    this.currentIndex = 3,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  _SettlementView _selectedView = _SettlementView.overview;

  void _showSettlementResult(BuildContext context) {
    final scale = ResponsiveScope.scaleOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: const Color(0xFF152523).withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResponsiveScope(
          scale: scale,
          child: const SettlementResultSheet(),
        );
      },
    );
  }

  List<Widget> _contentForSelectedView() {
    switch (_selectedView) {
      case _SettlementView.overview:
        return const [
          _PayersCard(compact: true),
          ResponsiveGap(height: 10),
          _PlacesSpendCard(compact: true),
        ];
      case _SettlementView.payer:
        return const [_PayersCard(compact: false)];
      case _SettlementView.place:
        return const [
          _PlacesSpendCard(compact: false),
          ResponsiveGap(height: 10),
          _PlaceDetailsCard(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      children: [
                        ListView(
                          padding: context.insetsFromLTRB(18, 8, 18, 88),
                          children: [
                            const _SettlementHeader(),
                            const ResponsiveGap(height: 10),
                            const _TotalSummaryCard(),
                            const ResponsiveGap(height: 10),
                            _SettlementTabs(
                              selectedView: _selectedView,
                              onChanged: (view) {
                                setState(() => _selectedView = view);
                              },
                            ),
                            const ResponsiveGap(height: 10),
                            ..._contentForSelectedView(),
                            const ResponsiveGap(height: 10),
                            const _MySettlementCards(),
                            const ResponsiveGap(height: 10),
                            _PrimarySettlementButton(
                              onTap: () => _showSettlementResult(context),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: widget.currentIndex,
                            onItemSelected: widget.onNavigationSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettlementHeader extends StatelessWidget {
  const _SettlementHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          Container(
            width: context.rs(30),
            height: context.rs(30),
            decoration: BoxDecoration(
              color: const Color(0xFF148776),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: context.rs(16),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '여행 정산',
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(18),
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 2),
                Text(
                  '제주 봄 여행 · 여행 종료',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: SizedBox(
                width: context.rs(34),
                height: context.rs(34),
                child: Icon(
                  Icons.download_rounded,
                  color: const Color(0xFF152523),
                  size: context.rs(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalSummaryCard extends StatelessWidget {
  const _TotalSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B5F55),
        borderRadius: BorderRadius.circular(context.rs(16)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C5547).withValues(alpha: 0.12),
            blurRadius: context.rs(22),
            offset: Offset(0, context.rs(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: const Color(0xFFBEECE3),
                    size: context.rs(15),
                  ),
                  const ResponsiveGap(width: 6),
                  Text(
                    '총지출 · 23건',
                    style: TextStyle(
                      color: const Color(0xFFBEECE3),
                      fontSize: context.rs(11),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const _SmallPill(
                label: '검토 완료',
                foreground: Color(0xFF2F9D69),
                background: Color(0xFFE5F6EE),
              ),
            ],
          ),
          const ResponsiveGap(height: 10),
          Text(
            '₩1,284,600',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rs(26),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const ResponsiveGap(height: 12),
          Row(
            children: const [
              Expanded(
                child: _SummaryFact(label: '1인 평균', value: '₩321,150'),
              ),
              ResponsiveGap(width: 8),
              Expanded(
                child: _SummaryFact(label: '정산 대상', value: '4명 · 18건'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryFact extends StatelessWidget {
  const _SummaryFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.rs(9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
          const ResponsiveGap(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rs(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementTabs extends StatelessWidget {
  const _SettlementTabs({required this.selectedView, required this.onChanged});

  final _SettlementView selectedView;
  final ValueChanged<_SettlementView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(34),
      padding: EdgeInsets.all(context.rs(3)),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F2),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          _SettlementTab(
            label: '한눈에',
            isActive: selectedView == _SettlementView.overview,
            onTap: () => onChanged(_SettlementView.overview),
          ),
          _SettlementTab(
            label: '결제자별',
            isActive: selectedView == _SettlementView.payer,
            onTap: () => onChanged(_SettlementView.payer),
          ),
          _SettlementTab(
            label: '장소별',
            isActive: selectedView == _SettlementView.place,
            onTap: () => onChanged(_SettlementView.place),
          ),
        ],
      ),
    );
  }
}

class _SettlementTab extends StatelessWidget {
  const _SettlementTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(context.rs(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(8)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0B5F55)
                    : const Color(0xFF60706D),
                fontSize: context.rs(11),
                fontWeight: isActive ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PayersCard extends StatelessWidget {
  const _PayersCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final payers = compact ? _payers.take(3).toList() : _payers;

    return _SettlementCard(
      child: Column(
        children: [
          const _CardHeader(title: '결제자별 내역', action: '전체 4명'),
          const ResponsiveGap(height: 9),
          ...List.generate(payers.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(index == payers.length - 1 ? 0 : 9),
              ),
              child: _PayerRow(payer: payers[index], compact: compact),
            );
          }),
        ],
      ),
    );
  }
}

class _PayerRow extends StatelessWidget {
  const _PayerRow({required this.payer, required this.compact});

  final _PayerData payer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          initial: payer.initial,
          color: payer.avatarColor,
          size: 28,
          fontSize: 10,
        ),
        const ResponsiveGap(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payer.name,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const ResponsiveGap(height: 2),
              Text(
                compact ? payer.overviewDetail : payer.payerDetail,
                style: TextStyle(
                  color: const Color(0xFF8A9895),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: context.rs(compact ? 66 : 72),
          child: Text(
            payer.amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlacesSpendCard extends StatelessWidget {
  const _PlacesSpendCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rows = compact ? _overviewPlaceSpends : _placeSpends;

    return _SettlementCard(
      child: Column(
        children: [
          _CardHeader(title: '장소별 지출', action: compact ? '상세 보기' : '5개 장소'),
          const ResponsiveGap(height: 10),
          ...List.generate(rows.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(index == rows.length - 1 ? 0 : 9),
              ),
              child: _PlaceSpendRow(data: rows[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _PlaceSpendRow extends StatelessWidget {
  const _PlaceSpendRow({required this.data});

  final _PlaceSpendData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.rs(54),
          child: Text(
            data.label,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const ResponsiveGap(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: context.rs(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3F2),
                  borderRadius: BorderRadius.circular(context.rs(999)),
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * data.ratio,
                  height: context.rs(7),
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(context.rs(999)),
                  ),
                ),
              );
            },
          ),
        ),
        const ResponsiveGap(width: 8),
        SizedBox(
          width: context.rs(58),
          child: Text(
            data.amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceDetailsCard extends StatelessWidget {
  const _PlaceDetailsCard();

  @override
  Widget build(BuildContext context) {
    return _SettlementCard(
      child: Column(
        children: [
          const _CardHeader(title: '장소별 결제 내역', action: '23건'),
          const ResponsiveGap(height: 10),
          ...List.generate(_placeDetails.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(index == _placeDetails.length - 1 ? 0 : 10),
              ),
              child: _PlaceDetailItem(data: _placeDetails[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _PlaceDetailItem extends StatelessWidget {
  const _PlaceDetailItem({required this.data});

  final _PlaceDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SmallPill(
                label: data.place,
                foreground: data.color,
                background: data.background,
              ),
              const ResponsiveGap(width: 8),
              Expanded(
                child: Text(
                  data.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                data.amount,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Column(
            children: data.payments
                .map(
                  (payment) => Padding(
                    padding: EdgeInsets.only(bottom: context.rs(6)),
                    child: _PaymentRow(payment: payment),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final _PaymentData payment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          initial: payment.initial,
          color: payment.avatarColor,
          size: 24,
          fontSize: 9,
        ),
        const ResponsiveGap(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.name,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const ResponsiveGap(height: 2),
              Text(
                payment.detail,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MySettlementCards extends StatelessWidget {
  const _MySettlementCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _AmountCard(
            label: '내가 보낼 금액',
            amount: '₩92,450',
            target: '민지에게',
            accent: Color(0xFFF27864),
            background: Color(0xFFFFF0EC),
          ),
        ),
        ResponsiveGap(width: 8),
        Expanded(
          child: _AmountCard(
            label: '내가 받을 금액',
            amount: '₩36,900',
            target: '서준에게',
            accent: Color(0xFF2F9D69),
            background: Color(0xFFE5F6EE),
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.amount,
    required this.target,
    required this.accent,
    required this.background,
  });

  final String label;
  final String amount;
  final String target;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
          const ResponsiveGap(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(18),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const ResponsiveGap(height: 4),
          Text(
            target,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimarySettlementButton extends StatelessWidget {
  const _PrimarySettlementButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: SizedBox(
          height: context.rs(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: context.rs(17),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '정산 완료로 표시',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(14),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: const Color(0xFF148776),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.rs(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initial,
    required this.color,
    required this.size,
    required this.fontSize,
  });

  final String initial;
  final Color color;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(size),
      height: context.rs(size),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: context.rs(2)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(fontSize),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _PayerData {
  const _PayerData({
    required this.initial,
    required this.name,
    required this.overviewDetail,
    required this.payerDetail,
    required this.amount,
    required this.avatarColor,
  });

  final String initial;
  final String name;
  final String overviewDetail;
  final String payerDetail;
  final String amount;
  final Color avatarColor;
}

class _PlaceSpendData {
  const _PlaceSpendData({
    required this.label,
    required this.amount,
    required this.color,
    required this.ratio,
  });

  final String label;
  final String amount;
  final Color color;
  final double ratio;
}

class _PlaceDetailData {
  const _PlaceDetailData({
    required this.place,
    required this.summary,
    required this.amount,
    required this.color,
    required this.background,
    required this.payments,
  });

  final String place;
  final String summary;
  final String amount;
  final Color color;
  final Color background;
  final List<_PaymentData> payments;
}

class _PaymentData {
  const _PaymentData({
    required this.initial,
    required this.name,
    required this.detail,
    required this.avatarColor,
  });

  final String initial;
  final String name;
  final String detail;
  final Color avatarColor;
}

const _payers = [
  _PayerData(
    initial: '민',
    name: '민지',
    overviewDetail: '숙소 외 5건',
    payerDetail: '8건 · ₩582,000',
    amount: '₩582,000',
    avatarColor: Color(0xFFDDEEF9),
  ),
  _PayerData(
    initial: '나',
    name: '나',
    overviewDetail: '렌터카 외 7건',
    payerDetail: '7건 · ₩401,600',
    amount: '₩401,600',
    avatarColor: Color(0xFFDDF3EE),
  ),
  _PayerData(
    initial: '서',
    name: '서준',
    overviewDetail: '식비 외 4건',
    payerDetail: '4건 · ₩221,000',
    amount: '₩221,000',
    avatarColor: Color(0xFFFFE8D9),
  ),
  _PayerData(
    initial: '하',
    name: '하늘',
    overviewDetail: '관광지 외 3건',
    payerDetail: '4건 · ₩80,000',
    amount: '₩80,000',
    avatarColor: Color(0xFFF3E8FF),
  ),
];

const _overviewPlaceSpends = [
  _PlaceSpendData(
    label: '숙소',
    amount: '₩480,000',
    color: Color(0xFF148776),
    ratio: 0.84,
  ),
  _PlaceSpendData(
    label: '교통',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    ratio: 0.58,
  ),
  _PlaceSpendData(
    label: '식비',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    ratio: 0.47,
  ),
];

const _placeSpends = [
  _PlaceSpendData(
    label: '숙소',
    amount: '₩480,000',
    color: Color(0xFF148776),
    ratio: 0.84,
  ),
  _PlaceSpendData(
    label: '렌터카',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    ratio: 0.58,
  ),
  _PlaceSpendData(
    label: '성산항',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    ratio: 0.47,
  ),
  _PlaceSpendData(
    label: '식당',
    amount: '₩208,000',
    color: Color(0xFFF4B740),
    ratio: 0.36,
  ),
  _PlaceSpendData(
    label: '관광지',
    amount: '₩1,000',
    color: Color(0xFF8A9895),
    ratio: 0.28,
  ),
];

const _placeDetails = [
  _PlaceDetailData(
    place: '숙소',
    summary: '2건 · 민지',
    amount: '₩480,000',
    color: Color(0xFF0B5F55),
    background: Color(0xFFDDF3EE),
    payments: [
      _PaymentData(
        initial: '민',
        name: '민지',
        detail: '4/12 · ₩320,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
      _PaymentData(
        initial: '민',
        name: '민지',
        detail: '4/13 · ₩160,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
    ],
  ),
  _PlaceDetailData(
    place: '렌터카',
    summary: '3건 · 나',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    background: Color(0xFFDDEEF9),
    payments: [
      _PaymentData(
        initial: '나',
        name: '나',
        detail: '4/10 · ₩180,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
      _PaymentData(
        initial: '나',
        name: '나',
        detail: '4/11 · ₩98,600',
        avatarColor: Color(0xFFDDF3EE),
      ),
      _PaymentData(
        initial: '나',
        name: '나',
        detail: '4/13 · ₩50,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
    ],
  ),
  _PlaceDetailData(
    place: '성산항',
    summary: '2건 · 서준',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    background: Color(0xFFFFE8D9),
    payments: [
      _PaymentData(
        initial: '서',
        name: '서준',
        detail: '4/11 · ₩150,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
      _PaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩117,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
    ],
  ),
  _PlaceDetailData(
    place: '식당',
    summary: '4건 · 민지, 나, 서준',
    amount: '₩208,000',
    color: Color(0xFFB8860B),
    background: Color(0xFFFFF7D6),
    payments: [
      _PaymentData(
        initial: '민',
        name: '민지',
        detail: '4/10 · ₩45,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
      _PaymentData(
        initial: '나',
        name: '나',
        detail: '4/11 · ₩63,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
      _PaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩50,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
      _PaymentData(
        initial: '민',
        name: '민지',
        detail: '4/13 · ₩50,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
    ],
  ),
  _PlaceDetailData(
    place: '관광지',
    summary: '1건 · 서준',
    amount: '₩1,000',
    color: Color(0xFF60706D),
    background: Color(0xFFF1F4F3),
    payments: [
      _PaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩1,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
    ],
  ),
];
