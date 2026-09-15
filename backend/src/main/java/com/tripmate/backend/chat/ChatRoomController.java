package com.tripmate.backend.chat;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.chat.dto.ChatMessageResponse;
import com.tripmate.backend.chat.dto.ChatRoomResponse;
import com.tripmate.backend.chat.dto.SendChatMessageRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/chat")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;
    private final AuthUserIdResolver authUserIdResolver;

    public ChatRoomController(
            ChatRoomService chatRoomService,
            AuthUserIdResolver authUserIdResolver
    ) {
        this.chatRoomService = chatRoomService;
        this.authUserIdResolver = authUserIdResolver;
    }

    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomResponse>> getChatRooms(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(chatRoomService.getChatRooms(userId));
    }

    @GetMapping("/rooms/{tripId}/messages")
    public ResponseEntity<List<ChatMessageResponse>> getMessages(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(chatRoomService.getMessages(tripId, userId));
    }

    @PostMapping("/rooms/{tripId}/messages")
    public ResponseEntity<ChatMessageResponse> sendMessage(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody SendChatMessageRequest request
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);
        ChatMessageResponse response = chatRoomService.sendMessage(
                tripId,
                userId,
                request
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
