package com.tripmate.backend.settlement;

import java.util.*;

public final class SettlementCalculator {
    private SettlementCalculator() {}
    public record Cost(long amount, long payerId, List<Long> participantIds) {}
    public record Balance(long userId, long paidAmount, long shareAmount, int expenseCount) {
        public long balance() { return paidAmount - shareAmount; }
    }
    public record Transfer(long fromUserId, long toUserId, long amount) {}
    public record Result(long totalAmount, List<Balance> balances, List<Transfer> transfers) {}

    public static Result calculate(Collection<Long> memberIds, List<Cost> costs) {
        var paid = new TreeMap<Long, Long>();
        var shares = new TreeMap<Long, Long>();
        var counts = new HashMap<Long, Integer>();
        for (long id : memberIds) { paid.put(id, 0L); shares.put(id, 0L); counts.put(id, 0); }
        long total = 0;
        for (Cost cost : costs) {
            var participants = cost.participantIds().stream().distinct().sorted().toList();
            if (cost.amount() <= 0 || !paid.containsKey(cost.payerId()) || participants.isEmpty()
                    || !paid.keySet().containsAll(participants)) {
                throw new IllegalArgumentException("Invalid settlement cost");
            }
            total = Math.addExact(total, cost.amount());
            paid.put(cost.payerId(), Math.addExact(paid.get(cost.payerId()), cost.amount()));
            counts.merge(cost.payerId(), 1, Integer::sum);
            long quotient = cost.amount() / participants.size();
            long remainder = cost.amount() % participants.size();
            for (int i = 0; i < participants.size(); i++) {
                long id = participants.get(i);
                shares.put(id, Math.addExact(shares.get(id), quotient + (i < remainder ? 1 : 0)));
            }
        }
        var balances = paid.keySet().stream().map(id -> new Balance(id, paid.get(id), shares.get(id), counts.get(id))).toList();
        var creditors = new LinkedHashMap<Long, Long>();
        var debtors = new LinkedHashMap<Long, Long>();
        for (Balance balance : balances) {
            if (balance.balance() > 0) creditors.put(balance.userId(), balance.balance());
            if (balance.balance() < 0) debtors.put(balance.userId(), -balance.balance());
        }
        var transfers = new ArrayList<Transfer>();
        for (var debtor : debtors.entrySet()) {
            long remaining = debtor.getValue();
            for (var creditor : creditors.entrySet()) {
                long amount = Math.min(remaining, creditor.getValue());
                if (amount == 0) continue;
                transfers.add(new Transfer(debtor.getKey(), creditor.getKey(), amount));
                creditor.setValue(creditor.getValue() - amount);
                remaining -= amount;
                if (remaining == 0) break;
            }
        }
        return new Result(total, balances, List.copyOf(transfers));
    }
}
