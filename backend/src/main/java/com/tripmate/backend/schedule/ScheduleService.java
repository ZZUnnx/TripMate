package com.tripmate.backend.schedule;

import com.tripmate.backend.schedule.dto.ScheduleRequest;
import com.tripmate.backend.schedule.dto.ScheduleResponse;
import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripRepository;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Objects;

@Service
public class ScheduleService {

    private final TripRepository tripRepository;
    private final ScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    public ScheduleService(
            TripRepository tripRepository,
            ScheduleRepository scheduleRepository,
            UserRepository userRepository
    ) {
        this.tripRepository = tripRepository;
        this.scheduleRepository = scheduleRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getSchedules(Long tripId, Long userId) {
        findAccessibleTrip(tripId, userId);

        return scheduleRepository
                .findByTripIdOrderBySchedule(tripId)
                .stream()
                .map(ScheduleResponse::from)
                .toList();
    }

    @Transactional
    public ScheduleResponse createSchedule(
            Long tripId,
            Long userId,
            ScheduleRequest request
    ) {
        Trip trip = lockAccessibleTrip(tripId, userId);
        return saveSchedule(trip, userId, request);
    }

    public record ImportResult(boolean created, ScheduleResponse schedule) {}

    @Transactional(isolation = org.springframework.transaction.annotation.Isolation.READ_COMMITTED)
    public ImportResult importSchedule(Long tripId, Long userId, ScheduleRequest request) {
        Trip trip = lockAccessibleTrip(tripId, userId);
        for (Schedule existing : scheduleRepository.findByTripIdOrderBySchedule(tripId)) {
            if (Objects.equals(existing.getScheduledDate(), request.scheduledDate())
                    && Objects.equals(existing.getScheduledTime(), request.scheduledTime())
                    && comparisonText(existing.getTitle()).equals(comparisonText(request.title()))
                    && comparisonText(existing.getPlaceName()).equals(comparisonText(request.placeName()))) {
                return new ImportResult(false, ScheduleResponse.from(existing));
            }
        }
        return new ImportResult(true, saveSchedule(trip, userId, request));
    }

    private Trip lockAccessibleTrip(Long tripId, Long userId) {
        findAccessibleTrip(tripId, userId);
        return tripRepository.findByIdForUpdate(tripId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }

    private static String comparisonText(String value) {
        return value == null ? "" : value.replaceAll("(?U)\\s+", "");
    }

    private ScheduleResponse saveSchedule(Trip trip, Long userId, ScheduleRequest request) {
        User creator = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "사용자를 찾을 수 없습니다."
                ));
        Schedule schedule = new Schedule(
                trip,
                request.title().trim(),
                normalizeCategory(request.category()),
                request.scheduledDate(),
                request.scheduledTime(),
                normalize(request.placeName()),
                normalize(request.url()),
                normalize(request.description()),
                request.sortOrder(),
                creator
        );

        return ScheduleResponse.from(scheduleRepository.save(schedule));
    }

    @Transactional
    public ScheduleResponse updateSchedule(
            Long scheduleId,
            Long userId,
            ScheduleRequest request
    ) {
        Schedule schedule = findAccessibleSchedule(scheduleId, userId);
        schedule.update(
                request.title().trim(),
                normalizeCategory(request.category()),
                request.scheduledDate(),
                request.scheduledTime(),
                normalize(request.placeName()),
                normalize(request.url()),
                normalize(request.description()),
                request.sortOrder()
        );

        return ScheduleResponse.from(schedule);
    }

    @Transactional
    public void deleteSchedule(Long scheduleId, Long userId) {
        Schedule schedule = findAccessibleSchedule(scheduleId, userId);

        scheduleRepository.delete(schedule);
    }

    private Schedule findAccessibleSchedule(Long scheduleId, Long userId) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "일정을 찾을 수 없습니다."
                ));

        findAccessibleTrip(schedule.getTrip().getId(), userId);

        return schedule;
    }

    private Trip findAccessibleTrip(Long tripId, Long userId) {
        return tripRepository.findAccessibleChatRoom(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "여행방을 찾을 수 없습니다."
                ));
    }

    private String normalizeCategory(String value) {
        String normalized = normalize(value);

        return normalized == null ? "공유 여행" : normalized;
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }
}
