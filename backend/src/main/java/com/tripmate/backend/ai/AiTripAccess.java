package com.tripmate.backend.ai;

import com.tripmate.backend.trip.TripRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AiTripAccess {
    private final TripRepository tripRepository;

    public AiTripAccess(TripRepository tripRepository) {
        this.tripRepository = tripRepository;
    }

    public void requireAccess(Long tripId, Long userId) {
        tripRepository.findAccessibleChatRoom(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "여행방을 찾을 수 없습니다."
                ));
    }
}
