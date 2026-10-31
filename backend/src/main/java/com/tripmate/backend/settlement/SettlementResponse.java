package com.tripmate.backend.settlement;

import java.time.LocalDate;
import java.util.List;

public record SettlementResponse(
        Long tripId, String title, LocalDate startDate, LocalDate endDate,
        boolean completed, long totalAmount, int expenseCount,
        long myPayable, long myReceivable,
        List<Member> members, List<ExpenseItem> expenses,
        List<Payer> payers, List<Place> places, List<Transfer> transfers
) {
    public record Member(Long userId, String nickname) {}
    public record ExpenseItem(Long id, String title, long amount, Long payerId,
                              String payerNickname, String placeName, LocalDate expenseDate, List<Long> participantIds) {}
    public record Payer(Long userId, String nickname, long paidAmount, long shareAmount, long balance, int expenseCount) {}
    public record Place(String placeName, long totalAmount, List<ExpenseItem> expenses) {}
    public record Transfer(Long fromUserId, String fromNickname, Long toUserId, String toNickname, long amount) {}
}
