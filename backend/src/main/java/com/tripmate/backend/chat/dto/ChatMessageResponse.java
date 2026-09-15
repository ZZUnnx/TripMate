package com.tripmate.backend.chat.dto;

import com.tripmate.backend.chat.ChatMessage;

import java.time.LocalDateTime;

public record ChatMessageResponse(
        Long id,
        Long tripId,
        Long senderId,
        String senderNickname,
        String content,
        LocalDateTime sentAt,
        boolean mine
) {
    public static ChatMessageResponse from(ChatMessage message, Long currentUserId) {
        Long senderId = message.getSender().getId();

        return new ChatMessageResponse(
                message.getId(),
                message.getTrip().getId(),
                senderId,
                message.getSender().getNickname(),
                message.getContent(),
                message.getSentAt(),
                senderId.equals(currentUserId)
        );
    }
}
