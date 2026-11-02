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
                4. 단어가 다르더라도 같은 대상과 같은 활동을 의미하면 하나로 통합한다.
                5. 띄어쓰기, 오타, 줄임말, 동의어, 구어체 차이는 동일한 의미로 해석한다. 예를 들어 렌트카, 렌터카, 차 렌트는 같은 대상을 가리킬 수 있다. 
                호텔, 숙소, 숙박시설도 문맥상 같은 예약을 가리키면 하나로 통합한다.
                6. 동일한 장소라도 방문 날짜, 시간, 목적이 다르면 별개의 일정으로 구분한다.
                7. 동일한 예약에 대한 날짜, 금액, 인원, 예약 상태가 여러 메시지에 나뉘어 있으면 하나의 예약 항목에 통합한다.
                8. 동일한 비용에 대한 총액, 분담 인원, 1인당 금액이 나뉘어 언급되면 하나의 정산 항목으로 통합한다.
                9. 일정, 예약, 정산은 서로 다른 유형이므로 같은 대상을 가리켜도 필요한 경우 각각 추출한다.
                10. 채팅에 없는 정보를 임의로 만들지 않는다.
                11. 알 수 없는 값은 반드시 null로 작성한다.
                12. URL이 있으면 관련 항목의 url에 넣는다.
                13. 항목을 통합할 때 서로 다른 예약이나 비용을 잘못 합치지 않는다.

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
                - 정산 메시지가 이 예약과 동일한 대상을 가리키는 것이 명확하면 정산 항목뿐 아니라 해당 예약의 amount와 peopleCount에도 총액과 인원을 작성한다.
                - 숙소비와 호텔 예약, 렌터카 비용과 렌터카 예약 등은 날짜와 장소 및 대화 문맥으로 동일 예약인지 확인한다.
                - 같은 종류의 예약이 여러 개여서 연결이 불명확하면 금액을 임의로 배정하지 말고 null로 둔다. 1인당 금액을 총액으로 사용하지 않는다.

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
