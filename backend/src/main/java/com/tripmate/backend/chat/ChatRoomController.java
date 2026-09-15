package com.tripmate.backend.chat;

import com.tripmate.backend.auth.JwtUtil;
import com.tripmate.backend.chat.dto.ChatRoomResponse;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/chat")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;
    private final JwtUtil jwtUtil;

    public ChatRoomController(
            ChatRoomService chatRoomService,
            JwtUtil jwtUtil
    ) {
        this.chatRoomService = chatRoomService;
        this.jwtUtil = jwtUtil;
    }

    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomResponse>> getChatRooms(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = extractUserId(authorizationHeader);

        return ResponseEntity.ok(chatRoomService.getChatRooms(userId));
    }

    private Long extractUserId(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "로그인이 필요합니다."
            );
        }

        String token = authorizationHeader.substring("Bearer ".length());

        try {
            Claims claims = jwtUtil.parseToken(token);
            Object userId = claims.get("userId");

            if (userId instanceof Number number) {
                return number.longValue();
            }

            return Long.parseLong(String.valueOf(userId));
        } catch (JwtException | IllegalArgumentException e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "유효하지 않은 토큰입니다."
            );
        }
    }
}
