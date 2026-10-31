class SettlementMember {
  const SettlementMember({required this.userId, required this.nickname});
  final int userId;
  final String nickname;
  factory SettlementMember.fromJson(Map<String, dynamic> json) =>
      SettlementMember(
        userId: (json['userId'] as num).toInt(),
        nickname: json['nickname'] as String,
      );
}

class SettlementExpense {
  const SettlementExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.payerNickname,
    required this.date,
    required this.participantIds,
    this.placeName,
  });
  final int id;
  final String title;
  final int amount;
  final int payerId;
  final String payerNickname;
  final String? placeName;
  final DateTime date;
  final List<int> participantIds;
  factory SettlementExpense.fromJson(Map<String, dynamic> json) =>
      SettlementExpense(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        amount: (json['amount'] as num).toInt(),
        payerId: (json['payerId'] as num).toInt(),
        payerNickname: json['payerNickname'] as String,
        placeName: json['placeName'] as String?,
        date: DateTime.parse(json['expenseDate'] as String),
        participantIds: (json['participantIds'] as List)
            .map((id) => (id as num).toInt())
            .toList(),
      );
}

class ExpenseDraft {
  const ExpenseDraft({
    required this.title,
    required this.amount,
    required this.payerId,
    required this.date,
    required this.participantIds,
    this.placeName,
  });
  final String title;
  final int amount;
  final int payerId;
  final DateTime date;
  final List<int> participantIds;
  final String? placeName;
  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'amount': amount,
    'payerId': payerId,
    'expenseDate':
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'participantIds': participantIds,
    'placeName': placeName?.trim(),
  };
}

class SettlementPayer {
  const SettlementPayer({
    required this.userId,
    required this.nickname,
    required this.paidAmount,
    required this.shareAmount,
    required this.balance,
    required this.expenseCount,
  });
  final int userId;
  final String nickname;
  final int paidAmount;
  final int shareAmount;
  final int balance;
  final int expenseCount;
  factory SettlementPayer.fromJson(Map<String, dynamic> j) => SettlementPayer(
    userId: (j['userId'] as num).toInt(),
    nickname: j['nickname'] as String,
    paidAmount: (j['paidAmount'] as num).toInt(),
    shareAmount: (j['shareAmount'] as num).toInt(),
    balance: (j['balance'] as num).toInt(),
    expenseCount: (j['expenseCount'] as num).toInt(),
  );
}

class SettlementPlace {
  const SettlementPlace({
    required this.name,
    required this.totalAmount,
    required this.expenses,
  });
  final String name;
  final int totalAmount;
  final List<SettlementExpense> expenses;
  factory SettlementPlace.fromJson(Map<String, dynamic> j) => SettlementPlace(
    name: j['placeName'] as String,
    totalAmount: (j['totalAmount'] as num).toInt(),
    expenses: (j['expenses'] as List)
        .map(
          (item) => SettlementExpense.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
  );
}

class SettlementTransfer {
  const SettlementTransfer({
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.toNickname,
    required this.amount,
  });
  final int fromUserId;
  final String fromNickname;
  final int toUserId;
  final String toNickname;
  final int amount;
  factory SettlementTransfer.fromJson(Map<String, dynamic> j) =>
      SettlementTransfer(
        fromUserId: (j['fromUserId'] as num).toInt(),
        fromNickname: j['fromNickname'] as String,
        toUserId: (j['toUserId'] as num).toInt(),
        toNickname: j['toNickname'] as String,
        amount: (j['amount'] as num).toInt(),
      );
}

class SettlementData {
  const SettlementData({
    required this.tripId,
    required this.title,
    required this.completed,
    required this.totalAmount,
    required this.expenseCount,
    required this.myPayable,
    required this.myReceivable,
    required this.members,
    required this.expenses,
    required this.payers,
    required this.places,
    required this.transfers,
    this.startDate,
    this.endDate,
  });
  final int tripId;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool completed;
  final int totalAmount;
  final int expenseCount;
  final int myPayable;
  final int myReceivable;
  final List<SettlementMember> members;
  final List<SettlementExpense> expenses;
  final List<SettlementPayer> payers;
  final List<SettlementPlace> places;
  final List<SettlementTransfer> transfers;
  String get status =>
      completed ? '정산 완료' : (expenseCount == 0 ? '지출 등록 전' : '정산 진행 중');
  String get period {
    String format(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    if (startDate == null) return '여행 기간 미정';
    return endDate == null || endDate == startDate
        ? format(startDate!)
        : '${format(startDate!)} – ${format(endDate!)}';
  }

  factory SettlementData.fromJson(Map<String, dynamic> j) {
    List<T> read<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (j[key] as List)
            .map((item) => parse(Map<String, dynamic>.from(item as Map)))
            .toList();
    return SettlementData(
      tripId: (j['tripId'] as num).toInt(),
      title: j['title'] as String,
      startDate: DateTime.tryParse(j['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(j['endDate']?.toString() ?? ''),
      completed: j['completed'] == true,
      totalAmount: (j['totalAmount'] as num).toInt(),
      expenseCount: (j['expenseCount'] as num).toInt(),
      myPayable: (j['myPayable'] as num).toInt(),
      myReceivable: (j['myReceivable'] as num).toInt(),
      members: read('members', SettlementMember.fromJson),
      expenses: read('expenses', SettlementExpense.fromJson),
      payers: read('payers', SettlementPayer.fromJson),
      places: read('places', SettlementPlace.fromJson),
      transfers: read('transfers', SettlementTransfer.fromJson),
    );
  }
}

String settlementWon(int amount) =>
    '₩${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
