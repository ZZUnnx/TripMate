package com.tripmate.backend.ai;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.auth.JwtUtil;
import com.tripmate.backend.chat.ChatMessage;
import com.tripmate.backend.chat.ChatMessageRepository;
import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripRepository;
import com.tripmate.backend.user.User;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class AiAuthorizationTest {
    private static final String SECRET = "ai-authorization-test-secret-at-least-32-bytes";
    private final TripRepository trips = mock(TripRepository.class);
    private final ChatMessageRepository messages = mock(ChatMessageRepository.class);
    private final GeminiService gemini = mock(GeminiService.class);
    private final JwtUtil jwt = new JwtUtil(SECRET, 60_000);
    private final AuthUserIdResolver auth = new AuthUserIdResolver(jwt);
    private final AiTripAccess access = new AiTripAccess(trips);
    private final MockMvc mvc = MockMvcBuilders.standaloneSetup(
            new AiChatAnalysisController(new AiChatAnalysisService(messages, gemini, access), auth),
            new AiController(gemini, auth, access)
    ).build();

    private List<MockHttpServletRequestBuilder> requests() {
        return List.of(post("/api/trips/7/ai/analyze"),
                get("/api/ai/test").param("tripId", "7").param("message", "hello"));
    }

    @Test
    void missingInvalidAndExpiredTokensAreRejectedBeforeAnyDataAccess() throws Exception {
        String expired = new JwtUtil(SECRET, -60_000).generateToken(1L, "test@example.com", "test");
        for (String header : List.of("", "Basic invalid", "Bearer invalid", "Bearer " + expired)) {
            for (var request : requests()) {
                mvc.perform(request.header("Authorization", header)).andExpect(status().isUnauthorized());
            }
        }
        for (var request : requests()) {
            mvc.perform(request).andExpect(status().isUnauthorized());
        }
        verifyNoInteractions(trips, messages, gemini);
    }

    @Test
    void nonParticipantOrMissingTripCannotReadChatOrInvokeGemini() throws Exception {
        when(trips.findAccessibleChatRoom(7L, 9L)).thenReturn(Optional.empty());
        for (var request : requests()) {
            mvc.perform(request.header("Authorization", "Bearer " + jwt.generateToken(9L, "x@y.com", "x")))
                    .andExpect(status().isNotFound());
        }
        verify(trips, times(2)).findAccessibleChatRoom(7L, 9L);
        verifyNoInteractions(messages, gemini);
    }

    @Test
    void accessibleUserCanAnalyzeChatAndUseTestEndpoint() throws Exception {
        Trip trip = mock(Trip.class);
        when(trips.findAccessibleChatRoom(7L, 1L)).thenReturn(Optional.of(trip));
        User sender = mock(User.class);
        when(sender.getNickname()).thenReturn("member");
        when(messages.findByTrip_IdOrderBySentAtAsc(7L))
                .thenReturn(List.of(new ChatMessage(trip, sender, "Let's travel")));
        when(gemini.askGemini(anyString())).thenReturn("{\"items\":[]}");
        for (var request : requests()) {
            mvc.perform(request.header("Authorization", "Bearer " + jwt.generateToken(1L, "x@y.com", "x")))
                    .andExpect(status().isOk());
        }
        var order = inOrder(trips, messages, gemini);
        order.verify(trips).findAccessibleChatRoom(7L, 1L);
        order.verify(messages).findByTrip_IdOrderBySentAtAsc(7L);
        order.verify(gemini).askGemini(anyString());
        order.verify(trips).findAccessibleChatRoom(7L, 1L);
        order.verify(gemini).askGemini("hello");
    }

    @Test
    void testEndpointRequiresTripContext() throws Exception {
        mvc.perform(get("/api/ai/test").param("message", "hello")
                        .header("Authorization", "Bearer " + jwt.generateToken(1L, "x@y.com", "x")))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(trips, messages, gemini);
    }
}
