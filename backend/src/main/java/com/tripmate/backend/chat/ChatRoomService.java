package com.tripmate.backend.chat;

import com.tripmate.backend.chat.dto.ChatRoomResponse;
import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChatRoomService {

    private final TripRepository tripRepository;
    private final ChatMessageRepository chatMessageRepository;

    public ChatRoomService(
            TripRepository tripRepository,
            ChatMessageRepository chatMessageRepository
    ) {
        this.tripRepository = tripRepository;
        this.chatMessageRepository = chatMessageRepository;
    }

    @Transactional(readOnly = true)
    public List<ChatRoomResponse> getChatRooms(Long userId) {
        return tripRepository.findChatRoomsByUserId(userId)
                .stream()
                .map(this::toResponse)
                .sorted(ChatRoomService::compareByRecentMessage)
                .toList();
    }

    private ChatRoomResponse toResponse(Trip trip) {
        ChatMessage lastMessage = chatMessageRepository
                .findFirstByTrip_IdOrderBySentAtDesc(trip.getId())
                .orElse(null);

        return new ChatRoomResponse(
                trip.getId(),
                trip.getTitle(),
                trip.getDestination(),
                lastMessage == null ? null : lastMessage.getContent(),
                lastMessage == null ? null : lastMessage.getSender().getNickname(),
                lastMessage == null ? null : lastMessage.getSentAt(),
                0,
                false,
                lastMessage != null
        );
    }

    private static int compareByRecentMessage(
            ChatRoomResponse left,
            ChatRoomResponse right
    ) {
        LocalDateTime leftAt = left.lastMessageAt();
        LocalDateTime rightAt = right.lastMessageAt();

        if (leftAt == null && rightAt == null) {
            return 0;
        }

        if (leftAt == null) {
            return 1;
        }

        if (rightAt == null) {
            return -1;
        }

        return rightAt.compareTo(leftAt);
    }
}
