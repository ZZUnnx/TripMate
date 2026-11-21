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
    private final AiTripAccess aiTripAccess;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiChatAnalysisService(
            ChatMessageRepository chatMessageRepository,
            GeminiService geminiService,
            AiTripAccess aiTripAccess
    ) {
        this.chatMessageRepository = chatMessageRepository;
        this.geminiService = geminiService;
        this.aiTripAccess = aiTripAccess;
    }

    public AiAnalyzeResponse analyze(Long tripId, Long userId) {
        aiTripAccess.requireAccess(tripId, userId);

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
                당신은 TripMate 여행 채팅 분석 AI이다.

                아래 여행 참여자들의 채팅을 분석하여
                여행 관리에 필요한 내용을 추출해라.

                추출할 항목은 다음 3가지이다.

                1. SCHEDULE
                여행 중 방문 장소, 식사, 관광, 이동, 활동 등
                날짜나 시간과 관련된 일정이다.

                예:
                - OO월 OO일 오전 OO시 OO 도착
                - 첫날 오후 OO시 OO 이동
                - 저녁 OO시 OO에서 저녁 식사

                2. RESERVATION
                숙소, 식당, 항공권, 기차, 렌터카 등
                예약 또는 예매와 관련된 내용이다.

                예:
                - OO 숙소를 OO월 OO일부터 OO월 OO일까지 예약
                - OO행 기차를 오전 OO시에 예매
                - OO 렌터카 예약 완료

                3. SETTLEMENT
                여행 비용, 결제, 송금, 더치페이, 인원별 분담 등
                금액 정산과 관련된 내용이다.

                예:
                - 렌터카 OO원 OO명이서 나누자
                - 숙소비 OO원 결제
                - 한 명당 OO원 보내줘

                공통 규칙:
                1. 구체적인 여행 계획이나 일정 제안은 후보로 추출.
                2. 명시적인 동의가 없어도 등록 후보로 추출할 수 있다.
                3. 취소되거나 다른 내용으로 변경된 경우 최신 내용만 반영.
                4. 같은 내용이 여러 번 언급되면 하나만 반환.
                5. 채팅에 없는 정보를 임의로 만들지 않는다.
                6. 알 수 없는 값은 반드시 null로 작성.
                7. URL이 있으면 관련 항목의 url에 넣음.
                8. 서로 다른 의미의 내용을 억지로 하나의 항목으로 합치지 않는다.

                SCHEDULE 규칙:
                - type은 "SCHEDULE"
                - date는 정확한 날짜를 알 수 있을 때 YYYY-MM-DD 형식
                - time은 정확한 시간을 알 수 있을 때 HH:mm 형식
                - placeName에는 관련 장소
                - amount와 peopleCount는 null

                RESERVATION 규칙:
                - type은 "RESERVATION"
                - 예약 시작 날짜는 date에 YYYY-MM-DD 형식
                - 예약 종료 날짜가 있으면 endDate에 YYYY-MM-DD 형식
                - 예약 시간이 있으면 time에 HH:mm 형식
                - 숙소, 식당, 역 등의 장소는 placeName
                - amount와 peopleCount는 관련 정보가 명확할 때만 작성

                SETTLEMENT 규칙:
                - type은 "SETTLEMENT"
                - amount에는 총 금액을 숫자로만 작성
                - peopleCount에는 분담 인원을 숫자로 작성
                - 날짜, 시간, 장소 정보가 없으면 null
                - 금액을 알 수 없으면 amount는 null
                - 인원을 알 수 없으면 peopleCount는 null

                반드시 아래 JSON 구조로만 응답.
                설명이나 마크다운 코드블록은 절대 작성하지 않는다.

                {
                  "items": [
                    {
                      "type": "SCHEDULE",
                      "title": "OO 일정",
                      "date": "YYYY-MM-DD",
                      "endDate": null,
                      "time": "HH:mm",
                      "placeName": "OO 장소",
                      "amount": null,
                      "peopleCount": null,
                      "description": "OO 일정 설명",
                      "url": null
                    },
                    {
                      "type": "RESERVATION",
                      "title": "OO 예약",
                      "date": "YYYY-MM-DD",
                      "endDate": "YYYY-MM-DD",
                      "time": null,
                      "placeName": "OO 장소",
                      "amount": null,
                      "peopleCount": null,
                      "description": "OO 예약 설명",
                      "url": null
                    },
                    {
                      "type": "SETTLEMENT",
                      "title": "OO 비용",
                      "date": null,
                      "endDate": null,
                      "time": null,
                      "placeName": null,
                      "amount": 0,
                      "peopleCount": 0,
                      "description": "OO 비용 정산",
                      "url": null
                    }
                  ]
                }

                예시에 작성된 OO, YYYY-MM-DD, HH:mm, 0은 JSON 형식을 설명하기 위한 예시일 뿐이다.
                실제 응답에 예시값을 그대로 사용하지 않는다.
                반드시 채팅에서 직접 확인할 수 있는 값만 작성한다.
                확인할 수 없는 문자열 값은 null로 작성한다.
                확인할 수 없는 amount와 peopleCount도 null로 작성한다.

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
                    "Gemini 채팅 분석 결과를 처리하지 못했습니다. 응답: "
                            + geminiResponse,
                    e
            );
        }
    }
}
