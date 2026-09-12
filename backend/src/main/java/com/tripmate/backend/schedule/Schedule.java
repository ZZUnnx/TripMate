package com.tripmate.backend.schedule;

import com.tripmate.backend.trip.Trip;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "schedules")
@Getter
@NoArgsConstructor
public class Schedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 어느 여행의 일정인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    // 일정 제목
    @Column(nullable = false, length = 100)
    private String title;

    // 식당, 숙소, 관광, 교통 등
    @Column(nullable = false, length = 30)
    private String category;

    // 일정 날짜
    @Column(nullable = false)
    private LocalDate scheduledDate;

    // 일정 시간 (시간 미정일 수도 있음)
    private LocalTime scheduledTime;

    // 장소
    @Column(length = 100)
    private String placeName;

    // 관련 링크
    @Column(columnDefinition = "TEXT")
    private String url;

    // 일정 설명
    @Column(columnDefinition = "TEXT")
    private String description;

    // 같은 날 일정 표시 순서
    @Column(nullable = false)
    private Integer sortOrder;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        if (this.sortOrder == null) {
            this.sortOrder = 0;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}