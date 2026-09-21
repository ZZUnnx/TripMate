package com.tripmate.backend.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripmate.backend.ai.dto.AiAnalyzeResponse;
import com.tripmate.backend.chat.ChatMessage;
import com.tripmate.backend.chat.ChatMessageRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AiChatAnalysisService {

    private final ChatMessageRepository chatMessageRepository;
    private final GeminiService geminiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiChatAnalysisService(
            ChatMessageRepository chatMessageRepository,
            GeminiService geminiService
    ) {
        this.chatMessageRepository = chatMessageRepository;
        this.geminiService = geminiService;
    }

    public AiAnalyzeResponse analyze(Long tripId) {

        List<ChatMessage> messages =
                chatMessageRepository
                        .findByTrip_IdOrderBySentAtAsc(tripId);

        if (messages.isEmpty()) {
            throw new IllegalArgumentException(
                    "분석할 채팅 메시지가 없습니다."
            );
        }

        StringBuilder chatText = new StringBuilder();

        for (ChatMessage message : messages) {
            chatText
                    .append("[")
                    .append(message.getSentAt())
                    .append("] ")
                    .append(message.getSender().getNickname())
                    .append(": ")
                    .append(message.getContent())
                    .append("\n");
        }

        String prompt = """
                당신은 TripMate 여행 채팅 분석 AI입니다.

                아래 여행 참여자들의 채팅 내용을 분석해서
                실제로 합의되거나 결정된 여행 일정만 추출하세요.

                규칙:
                1. 단순 제안만 있고 합의되지 않은 내용은 제외하세요.
                2. 취소되거나 다른 의견으로 변경된 일정은 제외하세요.
                3. 같은 일정이 여러 번 언급되어도 하나만 반환하세요.
                4. 채팅에 없는 정보를 임의로 만들어내지 마세요.
                5. 알 수 없는 값은 null로 작성하세요.
                6. type은 반드시 "SCHEDULE"로 작성하세요.
                7. date는 알 수 있다면 YYYY-MM-DD 형식으로 작성하세요.
                8. time은 알 수 있다면 HH:mm 형식으로 작성하세요.
                9. URL이 채팅에 포함되어 있으면 관련 일정에 포함하세요.

                반드시 아래 JSON 형식으로만 응답하세요.
                설명, 마크다운, ```json 같은 코드블록은 절대 추가하지 마세요.

                {
                  "items": [
                    {
                      "type": "SCHEDULE",
                      "title": "일정 제목",
                      "date": "YYYY-MM-DD",
                      "time": "HH:mm",
                      "placeName": "장소명",
                      "description": "설명",
                      "url": "URL"
                    }
                  ]
                }

                분석할 채팅:
                """ + chatText;

        String geminiResponse =
                geminiService.askGemini(prompt);

        try {
            return objectMapper.readValue(
                    geminiResponse,
                    AiAnalyzeResponse.class
            );

        } catch (Exception e) {
            throw new RuntimeException(
                    "Gemini 일정 분석 결과를 처리하지 못했습니다. 응답: "
                            + geminiResponse,
                    e
            );
        }
    }
}