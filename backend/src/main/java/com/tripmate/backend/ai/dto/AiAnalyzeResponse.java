package com.tripmate.backend.ai.dto;

import java.util.List;

public record AiAnalyzeResponse(
        List<AiAnalyzeItem> items
) {
}