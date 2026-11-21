package com.tripmate.backend.ai;

import com.tripmate.backend.ai.dto.AiAnalyzeResponse;
import com.tripmate.backend.auth.AuthUserIdResolver;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/trips/{tripId}/ai")
@CrossOrigin(origins = "*")
public class AiChatAnalysisController {

    private final AiChatAnalysisService aiChatAnalysisService;
    private final AuthUserIdResolver authUserIdResolver;

    public AiChatAnalysisController(
            AiChatAnalysisService aiChatAnalysisService,
            AuthUserIdResolver authUserIdResolver
    ) {
        this.aiChatAnalysisService = aiChatAnalysisService;
        this.authUserIdResolver = authUserIdResolver;
    }

    @PostMapping("/analyze")
    public ResponseEntity<AiAnalyzeResponse> analyze(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AiAnalyzeResponse response =
                aiChatAnalysisService.analyze(tripId, authUserIdResolver.resolve(authorizationHeader));

        return ResponseEntity.ok(response);
    }
}
