package com.tripmate.backend.settlement;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    List<Expense> findByTrip_IdOrderByExpenseDateDescIdDesc(Long tripId);
}
