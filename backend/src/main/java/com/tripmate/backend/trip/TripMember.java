package com.tripmate.backend.trip;

import com.tripmate.backend.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "trip_members",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"trip_id", "user_id"})
    }
)
@Getter
@NoArgsConstructor
public class TripMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 20)
    private String role;

    @Column(nullable = false)
    private LocalDateTime joinedAt;

    public TripMember(Trip trip, User user, String role) {
        this.trip = trip;
        this.user = user;
        this.role = role;
    }

    @PrePersist
    public void prePersist() {
        this.joinedAt = LocalDateTime.now();

        if (this.role == null) {
            this.role = "MEMBER";
        }
    }
}
