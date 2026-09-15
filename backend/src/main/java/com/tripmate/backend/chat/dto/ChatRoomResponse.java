package com.tripmate.backend.chat.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ChatRoomResponse(
        Long tripId,
        String title,
        String destination,
        LocalDate startDate,
        LocalDate endDate,
        long memberCount,
        String lastMessage,
        String lastSenderNickname,
        LocalDateTime lastMessageAt,
        int unreadCount,
        boolean pinned,
        boolean aiSummaryAvailable
) {
}
