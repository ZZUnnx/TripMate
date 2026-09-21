package com.tripmate.backend.ai;

import com.tripmate.backend.ai.dto.AiAnalyzeResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/trips/{tripId}/ai")
@CrossOrigin(origins = "*")
public class AiChatAnalysisController {

    private final AiChatAnalysisService aiChatAnalysisService;

    public AiChatAnalysisController(
            AiChatAnalysisService aiChatAnalysisService
    ) {
        this.aiChatAnalysisService = aiChatAnalysisService;
    }

    @PostMapping("/analyze")
    public ResponseEntity<AiAnalyzeResponse> analyze(
            @PathVariable Long tripId
    ) {
        AiAnalyzeResponse response =
                aiChatAnalysisService.analyze(tripId);

        return ResponseEntity.ok(response);
    }
}