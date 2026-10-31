package com.tripmate.backend.ai.dto;

public record AiAnalyzeItem(
        String type,          // SCHEDULE / RESERVATION / SETTLEMENT
        String title,

        // 일정/예약
        String date,
        String endDate,
        String time,
        String placeName,

        // 정산
        Integer amount,
        Integer peopleCount,

        // 공통
        String description,
        String url
) {
}