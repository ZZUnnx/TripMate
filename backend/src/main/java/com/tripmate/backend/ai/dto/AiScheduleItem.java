package com.tripmate.backend.ai.dto;

public record AiScheduleItem(
        String type,
        String title,
        String date,
        String time,
        String placeName,
        String description,
        String url
) {
}