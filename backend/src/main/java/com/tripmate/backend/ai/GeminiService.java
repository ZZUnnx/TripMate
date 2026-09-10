package com.tripmate.backend.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;

@Service
public class GeminiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private final RestClient restClient = RestClient.create();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String askGemini(String message) {

        String url =
                "https://generativelanguage.googleapis.com/v1beta/models/"
                + "gemini-3.6-flash:generateContent";

        GeminiRequest requestBody = new GeminiRequest(
                List.of(
                        new Content(
                                List.of(
                                        new Part(message)
                                )
                        )
                )
        );

        String response = restClient.post()
                .uri(url)
                .contentType(MediaType.APPLICATION_JSON)
                .header("x-goog-api-key", apiKey)
                .body(requestBody)
                .retrieve()
                .body(String.class);
        try {
            JsonNode root = objectMapper.readTree(response);

            JsonNode textNode = root.findValue("text");

            if (textNode != null) {
                return textNode.asText();
            }

            return "Gemini 응답에서 text를 찾지 못했습니다.";

        } catch (Exception e) {
            return "Gemini 응답 처리 중 오류: " + e.getMessage();
        }
    }

    public record GeminiRequest(List<Content> contents) {
    }

    public record Content(List<Part> parts) {
    }

    public record Part(String text) {
    }
}