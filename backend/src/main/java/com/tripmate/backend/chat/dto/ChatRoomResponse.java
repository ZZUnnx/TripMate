package com.tripmate.backend.chat.dto;

import java.time.LocalDateTime;

public record ChatRoomResponse(
        Long tripId,
        String title,
        String destination,
        String lastMessage,
        String lastSenderNickname,
        LocalDateTime lastMessageAt,
        int unreadCount,
        boolean pinned,
        boolean aiSummaryAvailable
) {
}
