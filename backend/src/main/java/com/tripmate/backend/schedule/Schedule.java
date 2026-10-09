package com.tripmate.backend.schedule;

import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.user.User;
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
    @Column(name = "schedule_date", nullable = false)
    private LocalDate scheduledDate;

    // 일정 시간 (시간 미정일 수도 있음)
    @Column(name = "start_time")
    private LocalTime scheduledTime;

    // 장소
    @Column(length = 100)
    private String placeName;

    // 관련 링크
    @Column(columnDefinition = "TEXT")
    private String url;

    // 일정 설명
    @Column(name = "memo", columnDefinition = "TEXT")
    private String description;

    // 같은 날 일정 표시 순서
    @Column(nullable = false)
    private Integer sortOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public Schedule(
            Trip trip,
            String title,
            String category,
            LocalDate scheduledDate,
            LocalTime scheduledTime,
            String placeName,
            String url,
            String description,
            Integer sortOrder,
            User createdBy
    ) {
        this.trip = trip;
        this.title = title;
        this.category = category;
        this.scheduledDate = scheduledDate;
        this.scheduledTime = scheduledTime;
        this.placeName = placeName;
        this.url = url;
        this.description = description;
        this.sortOrder = sortOrder;
        this.createdBy = createdBy;
    }

    public void update(
            String title,
            String category,
            LocalDate scheduledDate,
            LocalTime scheduledTime,
            String placeName,
            String url,
            String description,
            Integer sortOrder
    ) {
        this.title = title;
        this.category = category;
        this.scheduledDate = scheduledDate;
        this.scheduledTime = scheduledTime;
        this.placeName = placeName;
        this.url = url;
        this.description = description;
        this.sortOrder = sortOrder;
    }

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
