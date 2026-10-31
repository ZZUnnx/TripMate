package com.tripmate.backend.schedule;

import com.tripmate.backend.schedule.dto.ScheduleRequest;
import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripRepository;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ScheduleImportTest {
    private final TripRepository trips = mock(TripRepository.class);
    private final ScheduleRepository schedules = mock(ScheduleRepository.class);
    private final UserRepository users = mock(UserRepository.class);
    private final ScheduleService service = new ScheduleService(trips, schedules, users);
    private final Trip trip = mock(Trip.class);
    private final User user = mock(User.class);

    private ScheduleRequest request(String title, String place) {
        return new ScheduleRequest(title, null, LocalDate.of(2026, 10, 31),
                LocalTime.of(9, 30), place, null, null, 0);
    }

    private void accessible() {
        when(trips.findAccessibleChatRoom(7L, 1L)).thenReturn(Optional.of(trip));
        when(trips.findByIdForUpdate(7L)).thenReturn(Optional.of(trip));
        when(users.findById(1L)).thenReturn(Optional.of(user));
        when(schedules.save(any())).thenAnswer(call -> call.getArgument(0));
    }

    @Test
    void existingScheduleIsReturnedWithoutSavingDespiteWhitespaceDifferences() {
        accessible();
        var existing = new Schedule(trip, "점심 식사", "공유 여행", LocalDate.of(2026, 10, 31),
                LocalTime.of(9, 30), "서울 역", null, null, 0, user);
        when(schedules.findByTripIdOrderBySchedule(7L)).thenReturn(List.of(existing));
        var result = service.importSchedule(7L, 1L, request(" 점심식사 ", "서울역"));
        assertFalse(result.created());
        verify(schedules, never()).save(any());
        var order = inOrder(trips, schedules);
        order.verify(trips).findByIdForUpdate(7L);
        order.verify(schedules).findByTripIdOrderBySchedule(7L);
    }

    @Test
    void differentTitleAtSameTimeIsAllowedAfterUserSelection() {
        accessible();
        var existing = new Schedule(trip, "lunch", "shared", LocalDate.of(2026, 10, 31),
                LocalTime.of(9, 30), "station", null, null, 0, user);
        when(schedules.findByTripIdOrderBySchedule(7L)).thenReturn(List.of(existing));
        assertTrue(service.importSchedule(7L, 1L, request("meal", "station")).created());
        verify(schedules).save(any());
    }

    @Test
    void retryAfterResponseLossFindsPreviouslySavedSchedule() {
        accessible();
        var saved = new Schedule(trip, "tour", "shared", LocalDate.of(2026, 10, 31),
                LocalTime.of(9, 30), null, null, null, 0, user);
        when(schedules.findByTripIdOrderBySchedule(7L)).thenReturn(List.of(), List.of(saved));
        assertTrue(service.importSchedule(7L, 1L, request("tour", null)).created());
        assertFalse(service.importSchedule(7L, 1L, request("tour", " ")).created());
        verify(schedules, times(1)).save(any());
    }

    @Test
    void unauthorizedUserCannotImportOrInspectSchedules() {
        assertThrows(ResponseStatusException.class,
                () -> service.importSchedule(7L, 9L, request("tour", null)));
        verifyNoInteractions(schedules, users);
        verify(trips, never()).findByIdForUpdate(any());
    }
}
