package com.tripmate.backend.settlement;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "settlement_statuses")
@Getter
@NoArgsConstructor
public class SettlementStatus {
    @Id
    private Long tripId;
    private LocalDateTime completedAt;

    public SettlementStatus(Long tripId) { this.tripId = tripId; }
    public void setCompleted(boolean completed) {
        completedAt = completed ? LocalDateTime.now() : null;
    }
}
