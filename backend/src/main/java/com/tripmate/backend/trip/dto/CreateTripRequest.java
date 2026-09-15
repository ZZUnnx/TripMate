package com.tripmate.backend.trip.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record CreateTripRequest(
        @NotBlank(message = "여행방 이름은 필수입니다.")
        @Size(max = 100, message = "여행방 이름은 100자 이하여야 합니다.")
        String title,

        @Size(max = 100, message = "여행지는 100자 이하여야 합니다.")
        String destination,

        LocalDate startDate,

        LocalDate endDate
) {
}
