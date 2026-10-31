package com.tripmate.backend.settlement;

import org.junit.jupiter.api.Test;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class SettlementCalculatorTest {
    @Test
    void dividesRemaindersWithoutLosingMoney() {
        var result = SettlementCalculator.calculate(List.of(1L, 2L, 3L), List.of(
                new SettlementCalculator.Cost(100, 1, List.of(3L, 1L, 2L))));
        assertEquals(100, result.totalAmount());
        assertEquals(List.of(34L, 33L, 33L), result.balances().stream().map(SettlementCalculator.Balance::shareAmount).toList());
        assertEquals(List.of(new SettlementCalculator.Transfer(2, 1, 33), new SettlementCalculator.Transfer(3, 1, 33)), result.transfers());
    }

    @Test
    void dividesEachExpenseOnlyAmongSelectedParticipants() {
        var result = SettlementCalculator.calculate(List.of(1L, 2L, 3L), List.of(
                new SettlementCalculator.Cost(90, 1, List.of(2L, 3L)),
                new SettlementCalculator.Cost(30, 2, List.of(1L, 2L, 3L))));
        assertEquals(List.of(10L, 55L, 55L), result.balances().stream().map(SettlementCalculator.Balance::shareAmount).toList());
        assertEquals(List.of(new SettlementCalculator.Transfer(2, 1, 25), new SettlementCalculator.Transfer(3, 1, 55)), result.transfers());
    }

    @Test
    void noExpensesOrBalancedPaymentsNeedNoTransfers() {
        assertTrue(SettlementCalculator.calculate(List.of(1L), List.of()).transfers().isEmpty());
        assertTrue(SettlementCalculator.calculate(List.of(1L, 2L), List.of(
                new SettlementCalculator.Cost(10, 1, List.of(1L, 2L)),
                new SettlementCalculator.Cost(10, 2, List.of(1L, 2L)))).transfers().isEmpty());
    }

    @Test
    void rejectsForeignMembersAndInvalidAmounts() {
        assertThrows(IllegalArgumentException.class, () -> SettlementCalculator.calculate(List.of(1L), List.of(new SettlementCalculator.Cost(1, 2, List.of(1L)))));
        assertThrows(IllegalArgumentException.class, () -> SettlementCalculator.calculate(List.of(1L), List.of(new SettlementCalculator.Cost(1, 1, List.of(2L)))));
        assertThrows(IllegalArgumentException.class, () -> SettlementCalculator.calculate(List.of(1L), List.of(new SettlementCalculator.Cost(0, 1, List.of(1L)))));
        assertThrows(IllegalArgumentException.class, () -> SettlementCalculator.calculate(List.of(1L), List.of(new SettlementCalculator.Cost(1, 1, List.of()))));
    }

    @Test
    void transfersCancelEveryBalanceAcrossManyExpensePatterns() {
        var random = new Random(7);
        for (int iteration = 0; iteration < 100; iteration++) {
            var costs = new ArrayList<SettlementCalculator.Cost>();
            for (int i = 0; i < 20; i++) costs.add(new SettlementCalculator.Cost(random.nextInt(10000) + 1, random.nextInt(4) + 1,
                    i % 2 == 0 ? List.of(1L, 2L, 3L, 4L) : List.of(2L, 4L)));
            var result = SettlementCalculator.calculate(List.of(1L, 2L, 3L, 4L), costs);
            assertEquals(result.totalAmount(), result.balances().stream().mapToLong(SettlementCalculator.Balance::shareAmount).sum());
            var balances = new HashMap<Long, Long>();
            result.balances().forEach(balance -> balances.put(balance.userId(), balance.balance()));
            result.transfers().forEach(transfer -> {
                assertTrue(transfer.amount() > 0);
                balances.merge(transfer.fromUserId(), transfer.amount(), Long::sum);
                balances.merge(transfer.toUserId(), -transfer.amount(), Long::sum);
            });
            assertTrue(balances.values().stream().allMatch(value -> value == 0));
        }
    }
}
