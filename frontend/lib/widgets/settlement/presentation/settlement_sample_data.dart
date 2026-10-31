import 'package:flutter/material.dart';

class SettlementPayerData {
  const SettlementPayerData({
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

class SettlementPlaceSpendData {
  const SettlementPlaceSpendData({
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

class SettlementPlaceDetailData {
  const SettlementPlaceDetailData({
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
  final List<SettlementPaymentData> payments;
}

class SettlementPaymentData {
  const SettlementPaymentData({
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

const sampleSettlementPayers = [
  SettlementPayerData(
    initial: '민',
    name: '민지',
    overviewDetail: '숙소 외 5건',
    payerDetail: '8건 · ₩582,000',
    amount: '₩582,000',
    avatarColor: Color(0xFFDDEEF9),
  ),
  SettlementPayerData(
    initial: '나',
    name: '나',
    overviewDetail: '렌터카 외 7건',
    payerDetail: '7건 · ₩401,600',
    amount: '₩401,600',
    avatarColor: Color(0xFFDDF3EE),
  ),
  SettlementPayerData(
    initial: '서',
    name: '서준',
    overviewDetail: '식비 외 4건',
    payerDetail: '4건 · ₩221,000',
    amount: '₩221,000',
    avatarColor: Color(0xFFFFE8D9),
  ),
  SettlementPayerData(
    initial: '하',
    name: '하늘',
    overviewDetail: '관광지 외 3건',
    payerDetail: '4건 · ₩80,000',
    amount: '₩80,000',
    avatarColor: Color(0xFFF3E8FF),
  ),
];

const sampleOverviewPlaceSpends = [
  SettlementPlaceSpendData(
    label: '숙소',
    amount: '₩480,000',
    color: Color(0xFF148776),
    ratio: 0.84,
  ),
  SettlementPlaceSpendData(
    label: '교통',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    ratio: 0.58,
  ),
  SettlementPlaceSpendData(
    label: '식비',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    ratio: 0.47,
  ),
];

const samplePlaceSpends = [
  SettlementPlaceSpendData(
    label: '숙소',
    amount: '₩480,000',
    color: Color(0xFF148776),
    ratio: 0.84,
  ),
  SettlementPlaceSpendData(
    label: '렌터카',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    ratio: 0.58,
  ),
  SettlementPlaceSpendData(
    label: '성산항',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    ratio: 0.47,
  ),
  SettlementPlaceSpendData(
    label: '식당',
    amount: '₩208,000',
    color: Color(0xFFF4B740),
    ratio: 0.36,
  ),
  SettlementPlaceSpendData(
    label: '관광지',
    amount: '₩1,000',
    color: Color(0xFF8A9895),
    ratio: 0.28,
  ),
];

const samplePlaceDetails = [
  SettlementPlaceDetailData(
    place: '숙소',
    summary: '2건 · 민지',
    amount: '₩480,000',
    color: Color(0xFF0B5F55),
    background: Color(0xFFDDF3EE),
    payments: [
      SettlementPaymentData(
        initial: '민',
        name: '민지',
        detail: '4/12 · ₩320,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
      SettlementPaymentData(
        initial: '민',
        name: '민지',
        detail: '4/13 · ₩160,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
    ],
  ),
  SettlementPlaceDetailData(
    place: '렌터카',
    summary: '3건 · 나',
    amount: '₩328,600',
    color: Color(0xFF4E79C7),
    background: Color(0xFFDDEEF9),
    payments: [
      SettlementPaymentData(
        initial: '나',
        name: '나',
        detail: '4/10 · ₩180,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
      SettlementPaymentData(
        initial: '나',
        name: '나',
        detail: '4/11 · ₩98,600',
        avatarColor: Color(0xFFDDF3EE),
      ),
      SettlementPaymentData(
        initial: '나',
        name: '나',
        detail: '4/13 · ₩50,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
    ],
  ),
  SettlementPlaceDetailData(
    place: '성산항',
    summary: '2건 · 서준',
    amount: '₩267,000',
    color: Color(0xFFF27864),
    background: Color(0xFFFFE8D9),
    payments: [
      SettlementPaymentData(
        initial: '서',
        name: '서준',
        detail: '4/11 · ₩150,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
      SettlementPaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩117,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
    ],
  ),
  SettlementPlaceDetailData(
    place: '식당',
    summary: '4건 · 민지, 나, 서준',
    amount: '₩208,000',
    color: Color(0xFFB8860B),
    background: Color(0xFFFFF7D6),
    payments: [
      SettlementPaymentData(
        initial: '민',
        name: '민지',
        detail: '4/10 · ₩45,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
      SettlementPaymentData(
        initial: '나',
        name: '나',
        detail: '4/11 · ₩63,000',
        avatarColor: Color(0xFFDDF3EE),
      ),
      SettlementPaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩50,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
      SettlementPaymentData(
        initial: '민',
        name: '민지',
        detail: '4/13 · ₩50,000',
        avatarColor: Color(0xFFDDEEF9),
      ),
    ],
  ),
  SettlementPlaceDetailData(
    place: '관광지',
    summary: '1건 · 서준',
    amount: '₩1,000',
    color: Color(0xFF60706D),
    background: Color(0xFFF1F4F3),
    payments: [
      SettlementPaymentData(
        initial: '서',
        name: '서준',
        detail: '4/12 · ₩1,000',
        avatarColor: Color(0xFFFFE8D9),
      ),
    ],
  ),
];
