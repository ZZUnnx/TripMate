package com.tripmate.backend.trip.dto;

import com.tripmate.backend.trip.Trip;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record TripResponse(
        Long id,
        String title,
        String destination,
        LocalDate startDate,
        LocalDate endDate,
        Long ownerId,
        LocalDateTime createdAt
) {
    public static TripResponse from(Trip trip) {
        return new TripResponse(
                trip.getId(),
                trip.getTitle(),
                trip.getDestination(),
                trip.getStartDate(),
                trip.getEndDate(),
                trip.getOwner().getId(),
                trip.getCreatedAt()
        );
    }
}
