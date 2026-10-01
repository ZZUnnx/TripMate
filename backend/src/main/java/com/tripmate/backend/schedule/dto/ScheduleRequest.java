package com.tripmate.backend.schedule.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

public record ScheduleRequest(
        @NotBlank(message = "일정 제목은 필수입니다.")
        @Size(max = 100, message = "일정 제목은 100자 이하여야 합니다.")
        String title,

        @Size(max = 30, message = "일정 카테고리는 30자 이하여야 합니다.")
        String category,

        @NotNull(message = "일정 날짜는 필수입니다.")
        LocalDate scheduledDate,

        LocalTime scheduledTime,

        @Size(max = 100, message = "장소명은 100자 이하여야 합니다.")
        String placeName,

        String url,

        String description,

        Integer sortOrder
) {
}
