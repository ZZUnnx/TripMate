package com.tripmate.backend.chat;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.chat.dto.ChatRoomResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
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
}
