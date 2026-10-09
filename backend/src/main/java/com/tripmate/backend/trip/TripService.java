package com.tripmate.backend.trip;

import com.tripmate.backend.trip.dto.CreateTripRequest;
import com.tripmate.backend.trip.dto.TripResponse;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class TripService {

    private final TripRepository tripRepository;
    private final UserRepository userRepository;

    public TripService(
            TripRepository tripRepository,
            UserRepository userRepository
    ) {
        this.tripRepository = tripRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<TripResponse> getTrips(Long userId) {
        return tripRepository.findChatRoomsByUserId(userId)
                .stream()
                .map(TripResponse::from)
                .toList();
    }

    @Transactional
    public TripResponse createTrip(Long userId, CreateTripRequest request) {
        if (request.startDate() != null &&
                request.endDate() != null &&
                request.endDate().isBefore(request.startDate())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "종료일은 시작일보다 빠를 수 없습니다."
            );
        }

        User owner = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "사용자를 찾을 수 없습니다."
                ));

        Trip trip = new Trip(
                request.title().trim(),
                normalize(request.destination()),
                request.startDate(),
                request.endDate(),
                owner
        );

        return TripResponse.from(tripRepository.save(trip));
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }
}
