package com.tripmate.backend.schedule.dto;

import com.tripmate.backend.schedule.Schedule;
import com.tripmate.backend.trip.Trip;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record ScheduleResponse(
        Long id,
        Long tripId,
        String tripTitle,
        String tripDestination,
        LocalDate tripStartDate,
        LocalDate tripEndDate,
        String title,
        String category,
        LocalDate scheduledDate,
        LocalTime scheduledTime,
        String placeName,
        String url,
        String description,
        Integer sortOrder,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static ScheduleResponse from(Schedule schedule) {
        Trip trip = schedule.getTrip();

        return new ScheduleResponse(
                schedule.getId(),
                trip.getId(),
                trip.getTitle(),
                trip.getDestination(),
                trip.getStartDate(),
                trip.getEndDate(),
                schedule.getTitle(),
                schedule.getCategory(),
                schedule.getScheduledDate(),
                schedule.getScheduledTime(),
                schedule.getPlaceName(),
                schedule.getUrl(),
                schedule.getDescription(),
                schedule.getSortOrder(),
                schedule.getCreatedAt(),
                schedule.getUpdatedAt()
        );
    }
}
