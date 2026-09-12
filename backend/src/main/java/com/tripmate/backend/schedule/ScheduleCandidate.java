package com.tripmate.backend.schedule;

import com.tripmate.backend.trip.Trip;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "schedule_candidates")
@Getter
@NoArgsConstructor
public class ScheduleCandidate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 어떤 여행의 일정 후보인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    // 일정 제목
    @Column(nullable = false, length = 100)
    private String title;

    // 숙소, 식당, 관광, 교통 등
    @Column(nullable = false, length = 30)
    private String category;

    // 날짜가 명확하지 않을 수도 있으므로 nullable
    private LocalDate scheduledDate;

    // 시간도 대화에 없을 수 있음
    private LocalTime scheduledTime;

    // 장소명
    @Column(length = 100)
    private String placeName;

    // 공유된 링크
    @Column(columnDefinition = "TEXT")
    private String url;

    // AI가 추출한 원문 설명이나 요약
    @Column(columnDefinition = "TEXT")
    private String description;

    // PENDING / APPROVED / REJECTED
    @Column(nullable = false, length = 20)
    private String status;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();

        if (this.status == null) {
            this.status = "PENDING";
        }
    }
}