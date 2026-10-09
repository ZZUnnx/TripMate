package com.tripmate.backend.chat;

import com.tripmate.backend.chat.dto.ChatMessageResponse;
import com.tripmate.backend.chat.dto.SendChatMessageRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.server.ResponseStatusException;

import java.security.Principal;

@Controller
public class ChatStompController {

    private final ChatRoomService chatRoomService;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatStompController(
            ChatRoomService chatRoomService,
            SimpMessagingTemplate messagingTemplate
    ) {
        this.chatRoomService = chatRoomService;
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/trips/{tripId}/messages")
    public void sendMessage(
            @DestinationVariable Long tripId,
            @Valid @Payload SendChatMessageRequest request,
            Principal principal
    ) {
        if (principal == null) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Unauthorized"
            );
        }

        ChatMessageResponse response = chatRoomService.sendMessage(
                tripId,
                Long.parseLong(principal.getName()),
                request
        );

        messagingTemplate.convertAndSend(
                "/topic/trips/" + tripId + "/messages",
                response
        );
    }
}
