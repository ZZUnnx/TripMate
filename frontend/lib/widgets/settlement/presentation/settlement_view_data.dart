import 'package:flutter/material.dart';

import '../../../models/settlement.dart';

List<SettlementPayerData> settlementPayerRows(SettlementData data) => data
    .payers
    .map(
      (payer) => SettlementPayerData(
        initial: payer.nickname.characters.firstOrNull ?? '?',
        name: payer.nickname,
        overviewDetail: '${payer.expenseCount}건 결제',
        payerDetail: '분담액 ${settlementWon(payer.shareAmount)}',
        amount: settlementWon(payer.paidAmount),
        avatarColor: const Color(0xFFDDF3EE),
      ),
    )
    .toList();

List<SettlementPlaceSpendData> settlementPlaceRows(SettlementData data) => data
    .places
    .map(
      (place) => SettlementPlaceSpendData(
        label: place.name,
        amount: settlementWon(place.totalAmount),
        color: const Color(0xFF148776),
        ratio: data.totalAmount == 0 ? 0 : place.totalAmount / data.totalAmount,
      ),
    )
    .toList();

List<SettlementPlaceDetailData> settlementPlaceDetailRows(
  SettlementData data,
) => data.places
    .map(
      (place) => SettlementPlaceDetailData(
        place: place.name,
        summary: '${place.expenses.length}건',
        amount: settlementWon(place.totalAmount),
        color: const Color(0xFF0B5F55),
        background: const Color(0xFFDDF3EE),
        payments: place.expenses
            .map(
              (expense) => SettlementPaymentData(
                initial: expense.payerNickname.characters.firstOrNull ?? '?',
                name: expense.payerNickname,
                detail:
                    '${expense.title} · ${expense.date.month}/${expense.date.day} · ${settlementWon(expense.amount)}',
                avatarColor: const Color(0xFFDDF3EE),
              ),
            )
            .toList(),
      ),
    )
    .toList();

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
