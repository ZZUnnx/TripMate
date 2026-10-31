import 'package:frontend/models/settlement.dart';
import 'package:frontend/providers/auth_provider.dart';

class SettlementTestAuth extends AuthProvider {
  @override
  bool get isInitialized => true;
  @override
  String? get accessToken => 'test-token';
  @override
  int? get userId => 1;
}

SettlementData settlementFixture({
  int tripId = 1,
  String title = '제주 봄 여행',
  int amount = 10000,
  bool completed = false,
  bool empty = false,
}) {
  final members = [
    const SettlementMember(userId: 1, nickname: '민지'),
    const SettlementMember(userId: 2, nickname: '서준'),
  ];
  final expense = SettlementExpense(
    id: 9,
    title: '식사',
    amount: amount,
    payerId: 1,
    payerNickname: '민지',
    date: DateTime(2026, 10, 31),
    participantIds: const [1, 2],
    placeName: '식당',
  );
  return SettlementData(
    tripId: tripId,
    title: title,
    completed: completed,
    totalAmount: empty ? 0 : amount,
    expenseCount: empty ? 0 : 1,
    myPayable: 0,
    myReceivable: empty ? 0 : amount ~/ 2,
    members: members,
    startDate: DateTime(2026, 10, 31),
    endDate: DateTime(2026, 11, 2),
    expenses: empty ? [] : [expense],
    payers: [
      SettlementPayer(
        userId: 1,
        nickname: '민지',
        paidAmount: empty ? 0 : amount,
        shareAmount: empty ? 0 : amount - amount ~/ 2,
        balance: empty ? 0 : amount ~/ 2,
        expenseCount: empty ? 0 : 1,
      ),
      SettlementPayer(
        userId: 2,
        nickname: '서준',
        paidAmount: 0,
        shareAmount: empty ? 0 : amount ~/ 2,
        balance: empty ? 0 : -(amount ~/ 2),
        expenseCount: 0,
      ),
    ],
    places: empty
        ? []
        : [
            SettlementPlace(
              name: '식당',
              totalAmount: amount,
              expenses: [expense],
            ),
          ],
    transfers: empty
        ? []
        : [
            SettlementTransfer(
              fromUserId: 2,
              fromNickname: '서준',
              toUserId: 1,
              toNickname: '민지',
              amount: amount ~/ 2,
            ),
          ],
  );
}
