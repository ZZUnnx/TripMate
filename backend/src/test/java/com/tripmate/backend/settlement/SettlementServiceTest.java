package com.tripmate.backend.settlement;

import com.tripmate.backend.trip.*;
import com.tripmate.backend.user.User;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class SettlementServiceTest {
    private final TripRepository trips = mock(TripRepository.class);
    private final TripMemberRepository members = mock(TripMemberRepository.class);
    private final ExpenseRepository expenses = mock(ExpenseRepository.class);
    private final SettlementStatusRepository statuses = mock(SettlementStatusRepository.class);
    private final SettlementService service = new SettlementService(trips, members, expenses, statuses);

    private Trip accessibleTrip() {
        var trip = mock(Trip.class);
        var owner = mock(User.class);
        when(trip.getId()).thenReturn(7L);
        when(trip.getOwner()).thenReturn(owner);
        when(owner.getId()).thenReturn(1L);
        when(owner.getNickname()).thenReturn("owner");
        when(trips.findAccessibleChatRoom(7L, 1L)).thenReturn(Optional.of(trip));
        when(trips.findByIdForUpdate(7L)).thenReturn(Optional.of(trip));
        when(members.findByTrip_IdOrderByJoinedAtAsc(7L)).thenReturn(List.of());
        return trip;
    }

    @Test
    void outsidersCannotReadOrCreateExpenses() {
        when(trips.findAccessibleChatRoom(7L, 9L)).thenReturn(Optional.empty());
        assertThrows(ResponseStatusException.class, () -> service.get(7L, 9L));
        assertThrows(ResponseStatusException.class, () -> service.create(7L, 9L, new ExpenseRequest("cost", 10L, 9L, null, LocalDate.now(), List.of(9L))));
        verifyNoInteractions(expenses);
    }

    @Test
    void rejectsPayersOrParticipantsOutsideTheTrip() {
        accessibleTrip();
        assertThrows(ResponseStatusException.class, () -> service.create(7L, 1L, new ExpenseRequest("cost", 10L, 99L, null, LocalDate.now(), List.of(1L))));
        assertThrows(ResponseStatusException.class, () -> service.create(7L, 1L, new ExpenseRequest("cost", 10L, 1L, null, LocalDate.now(), List.of(99L))));
        verifyNoInteractions(expenses);
    }

    @Test
    void editingExpensesReopensACompletedSettlement() {
        var trip = accessibleTrip();
        var expense = new Expense(trip, new ExpenseRequest("cost", 10L, 1L, null, LocalDate.now(), List.of(1L)));
        var status = new SettlementStatus(7L);
        status.setCompleted(true);
        when(expenses.findById(3L)).thenReturn(Optional.of(expense));
        when(statuses.findById(7L)).thenReturn(Optional.of(status));
        service.update(3L, 1L, new ExpenseRequest("updated", 20L, 1L, null, LocalDate.now(), List.of(1L)));
        assertEquals(20L, expense.getAmount());
        assertNull(status.getCompletedAt());
    }

    @Test
    void emptyTripsCannotBeMarkedComplete() {
        accessibleTrip();
        when(expenses.findByTrip_IdOrderByExpenseDateDescIdDesc(7L)).thenReturn(List.of());
        assertThrows(ResponseStatusException.class, () -> service.complete(7L, 1L, true));
        verify(statuses, never()).save(any());
    }
}
