package com.tripmate.backend.chat;

import com.tripmate.backend.auth.AuthUserIdResolver;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.stereotype.Component;

import java.security.Principal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class StompAuthChannelInterceptor implements ChannelInterceptor {

    private static final Pattern TRIP_TOPIC_PATTERN =
            Pattern.compile("^/topic/trips/(\\d+)(?:/.*)?$");

    private final AuthUserIdResolver authUserIdResolver;
    private final ChatRoomService chatRoomService;

    public StompAuthChannelInterceptor(
            AuthUserIdResolver authUserIdResolver,
            ChatRoomService chatRoomService
    ) {
        this.authUserIdResolver = authUserIdResolver;
        this.chatRoomService = chatRoomService;
    }

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(
                message,
                StompHeaderAccessor.class
        );

        if (accessor == null || accessor.getCommand() == null) {
            return message;
        }

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            Long userId = authUserIdResolver.resolve(
                    accessor.getFirstNativeHeader("Authorization")
            );

            accessor.setUser(new StompPrincipal(userId));

            return message;
        }

        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            Long tripId = extractTripId(accessor.getDestination());

            if (tripId != null) {
                chatRoomService.verifyChatRoomAccess(
                        tripId,
                        resolveUserId(accessor)
                );
            }
        }

        return message;
    }

    private Long resolveUserId(StompHeaderAccessor accessor) {
        Principal principal = accessor.getUser();

        if (principal instanceof StompPrincipal stompPrincipal) {
            return stompPrincipal.userId();
        }

        if (principal != null) {
            return Long.parseLong(principal.getName());
        }

        return authUserIdResolver.resolve(
                accessor.getFirstNativeHeader("Authorization")
        );
    }

    private Long extractTripId(String destination) {
        if (destination == null) {
            return null;
        }

        Matcher matcher = TRIP_TOPIC_PATTERN.matcher(destination);

        if (!matcher.matches()) {
            return null;
        }

        return Long.parseLong(matcher.group(1));
    }
}
