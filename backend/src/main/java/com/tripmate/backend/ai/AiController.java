package com.tripmate.backend.ai;

import com.tripmate.backend.auth.AuthUserIdResolver;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController 
@RequestMapping("/api/ai")
public class AiController {
    
    private final GeminiService geminiService;
    private final AuthUserIdResolver authUserIdResolver;
    private final AiTripAccess aiTripAccess;

    public AiController(GeminiService geminiService, AuthUserIdResolver authUserIdResolver,
                        AiTripAccess aiTripAccess) {
        this.geminiService = geminiService;
        this.authUserIdResolver = authUserIdResolver;
        this.aiTripAccess = aiTripAccess;
    }

    @GetMapping("/test")
    public String test(@RequestParam String message, @RequestParam Long tripId,
                       @RequestHeader(value = "Authorization", required = false) String authorizationHeader) {
        aiTripAccess.requireAccess(tripId, authUserIdResolver.resolve(authorizationHeader));
        return geminiService.askGemini(message);
    }

}
