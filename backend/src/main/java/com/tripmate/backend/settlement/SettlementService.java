package com.tripmate.backend.settlement;

import com.tripmate.backend.trip.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.util.*;

@Service
public class SettlementService {
    private final TripRepository trips;
    private final TripMemberRepository tripMembers;
    private final ExpenseRepository expenses;
    private final SettlementStatusRepository statuses;

    public SettlementService(TripRepository trips, TripMemberRepository tripMembers,
                             ExpenseRepository expenses, SettlementStatusRepository statuses) {
        this.trips = trips;
        this.tripMembers = tripMembers;
        this.expenses = expenses;
        this.statuses = statuses;
    }

    @Transactional(readOnly = true)
    public List<SettlementResponse> list(Long userId) {
        return trips.findChatRoomsByUserId(userId).stream().map(trip -> build(trip, userId)).toList();
    }

    @Transactional(readOnly = true)
    public SettlementResponse get(Long tripId, Long userId) {
        return build(accessibleTrip(tripId, userId), userId);
    }

    @Transactional
    public void create(Long tripId, Long userId, ExpenseRequest request) {
        Trip trip = lockTrip(tripId, userId);
        validateMembers(trip, request);
        expenses.save(new Expense(trip, request));
        resetStatus(tripId);
    }

    @Transactional
    public void update(Long expenseId, Long userId, ExpenseRequest request) {
        Expense expense = findExpense(expenseId);
        Trip trip = lockTrip(expense.getTrip().getId(), userId);
        validateMembers(trip, request);
        expense.update(request);
        resetStatus(trip.getId());
    }

    @Transactional
    public void delete(Long expenseId, Long userId) {
        Expense expense = findExpense(expenseId);
        Trip trip = lockTrip(expense.getTrip().getId(), userId);
        expenses.delete(expense);
        resetStatus(trip.getId());
    }

    @Transactional
    public void complete(Long tripId, Long userId, boolean completed) {
        lockTrip(tripId, userId);
        if (completed && expenses.findByTrip_IdOrderByExpenseDateDescIdDesc(tripId).isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "등록된 지출이 없습니다.");
        }
        SettlementStatus status = statuses.findById(tripId).orElseGet(() -> new SettlementStatus(tripId));
        status.setCompleted(completed);
        statuses.save(status);
    }

    private void resetStatus(Long tripId) {
        statuses.findById(tripId).ifPresent(status -> status.setCompleted(false));
    }

    private Expense findExpense(Long id) {
        return expenses.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "지출을 찾을 수 없습니다."));
    }

    private Trip accessibleTrip(Long tripId, Long userId) {
        return trips.findAccessibleChatRoom(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "여행방을 찾을 수 없습니다."));
    }

    private Trip lockTrip(Long tripId, Long userId) {
        accessibleTrip(tripId, userId);
        return trips.findByIdForUpdate(tripId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }

    private Map<Long, String> members(Trip trip) {
        var members = new TreeMap<Long, String>();
        members.put(trip.getOwner().getId(), trip.getOwner().getNickname());
        for (TripMember member : tripMembers.findByTrip_IdOrderByJoinedAtAsc(trip.getId())) {
            members.put(member.getUser().getId(), member.getUser().getNickname());
        }
        return members;
    }

    private void validateMembers(Trip trip, ExpenseRequest request) {
        var ids = members(trip).keySet();
        if (!ids.contains(request.payerId()) || !ids.containsAll(request.participantIds())
                || new HashSet<>(request.participantIds()).size() != request.participantIds().size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "결제자와 분담 대상은 해당 여행의 참여자여야 합니다.");
        }
    }

    private SettlementResponse build(Trip trip, Long userId) {
        var members = members(trip);
        var entries = expenses.findByTrip_IdOrderByExpenseDateDescIdDesc(trip.getId());
        var calculation = SettlementCalculator.calculate(members.keySet(), entries.stream()
                .map(expense -> new SettlementCalculator.Cost(expense.getAmount(), expense.getPayerId(), List.copyOf(expense.getParticipantIds())))
                .toList());
        var items = entries.stream().map(expense -> new SettlementResponse.ExpenseItem(
                expense.getId(), expense.getTitle(), expense.getAmount(), expense.getPayerId(), members.get(expense.getPayerId()),
                expense.getPlaceName(), expense.getExpenseDate(), expense.getParticipantIds().stream().sorted().toList())).toList();
        var grouped = new LinkedHashMap<String, List<SettlementResponse.ExpenseItem>>();
        for (var item : items) grouped.computeIfAbsent(item.placeName() == null ? "장소 미지정" : item.placeName(), key -> new ArrayList<>()).add(item);
        var places = grouped.entrySet().stream().map(entry -> new SettlementResponse.Place(entry.getKey(),
                entry.getValue().stream().mapToLong(SettlementResponse.ExpenseItem::amount).sum(), entry.getValue())).toList();
        var transfers = calculation.transfers().stream().map(transfer -> new SettlementResponse.Transfer(
                transfer.fromUserId(), members.get(transfer.fromUserId()), transfer.toUserId(), members.get(transfer.toUserId()), transfer.amount())).toList();
        long myPayable = transfers.stream().filter(transfer -> transfer.fromUserId().equals(userId)).mapToLong(SettlementResponse.Transfer::amount).sum();
        long myReceivable = transfers.stream().filter(transfer -> transfer.toUserId().equals(userId)).mapToLong(SettlementResponse.Transfer::amount).sum();
        return new SettlementResponse(trip.getId(), trip.getTitle(), trip.getStartDate(), trip.getEndDate(),
                statuses.findById(trip.getId()).map(status -> status.getCompletedAt() != null).orElse(false),
                calculation.totalAmount(), items.size(), myPayable, myReceivable,
                members.entrySet().stream().map(entry -> new SettlementResponse.Member(entry.getKey(), entry.getValue())).toList(),
                items, calculation.balances().stream().map(balance -> new SettlementResponse.Payer(balance.userId(), members.get(balance.userId()),
                    balance.paidAmount(), balance.shareAmount(), balance.balance(), balance.expenseCount())).toList(), places, transfers);
    }
}
