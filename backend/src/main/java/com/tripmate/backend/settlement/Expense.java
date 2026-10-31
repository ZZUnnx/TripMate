package com.tripmate.backend.settlement;

import com.tripmate.backend.trip.Trip;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;

@Entity
@Table(name = "expenses")
@Getter
@NoArgsConstructor
public class Expense {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;
    @Column(nullable = false, length = 100)
    private String title;
    @Column(nullable = false)
    private Long amount;
    @Column(nullable = false)
    private Long payerId;
    @Column(length = 100)
    private String placeName;
    @Column(nullable = false)
    private LocalDate expenseDate;
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "expense_participants", joinColumns = @JoinColumn(name = "expense_id"),
            uniqueConstraints = @UniqueConstraint(columnNames = {"expense_id", "user_id"}))
    @Column(name = "user_id", nullable = false)
    private Set<Long> participantIds = new LinkedHashSet<>();

    public Expense(Trip trip, ExpenseRequest request) {
        this.trip = trip;
        update(request);
    }

    public void update(ExpenseRequest request) {
        title = request.title().trim();
        amount = request.amount();
        payerId = request.payerId();
        placeName = request.placeName() == null || request.placeName().isBlank() ? null : request.placeName().trim();
        expenseDate = request.expenseDate();
        participantIds.clear();
        participantIds.addAll(request.participantIds());
    }
}
