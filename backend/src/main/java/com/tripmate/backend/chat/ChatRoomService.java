package com.tripmate.backend.chat;

import com.tripmate.backend.chat.dto.ChatRoomResponse;
import com.tripmate.backend.chat.dto.ChatMessageResponse;
import com.tripmate.backend.chat.dto.SendChatMessageRequest;
import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripMemberRepository;
import com.tripmate.backend.trip.TripRepository;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChatRoomService {

    private final TripRepository tripRepository;
    private final TripMemberRepository tripMemberRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;

    public ChatRoomService(
            TripRepository tripRepository,
            TripMemberRepository tripMemberRepository,
            ChatMessageRepository chatMessageRepository,
            UserRepository userRepository
    ) {
        this.tripRepository = tripRepository;
        this.tripMemberRepository = tripMemberRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<ChatRoomResponse> getChatRooms(Long userId) {
        return tripRepository.findChatRoomsByUserId(userId)
                .stream()
                .map(this::toResponse)
                .sorted(ChatRoomService::compareByRecentMessage)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ChatMessageResponse> getMessages(Long tripId, Long userId) {
        findAccessibleTrip(tripId, userId);

        return chatMessageRepository.findByTrip_IdOrderBySentAtAsc(tripId)
                .stream()
                .map(message -> ChatMessageResponse.from(message, userId))
                .toList();
    }

    @Transactional
    public ChatMessageResponse sendMessage(
            Long tripId,
            Long userId,
            SendChatMessageRequest request
    ) {
        Trip trip = findAccessibleTrip(tripId, userId);
        User sender = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "사용자를 찾을 수 없습니다."
                ));
        ChatMessage message = new ChatMessage(
                trip,
                sender,
                request.content().trim()
        );

        return ChatMessageResponse.from(chatMessageRepository.save(message), userId);
    }

    private ChatRoomResponse toResponse(Trip trip) {
        ChatMessage lastMessage = chatMessageRepository
                .findFirstByTrip_IdOrderBySentAtDesc(trip.getId())
                .orElse(null);
        long memberCount = tripMemberRepository.countByTrip_Id(trip.getId()) + 1;

        return new ChatRoomResponse(
                trip.getId(),
                trip.getTitle(),
                trip.getDestination(),
                trip.getStartDate(),
                trip.getEndDate(),
                memberCount,
                lastMessage == null ? null : lastMessage.getContent(),
                lastMessage == null ? null : lastMessage.getSender().getNickname(),
                lastMessage == null ? null : lastMessage.getSentAt(),
                0,
                false,
                lastMessage != null
        );
    }

    private Trip findAccessibleTrip(Long tripId, Long userId) {
        return tripRepository.findAccessibleChatRoom(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "채팅방을 찾을 수 없습니다."
                ));
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
