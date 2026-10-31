package com.tripmate.backend.schedule;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.schedule.dto.ScheduleRequest;
import com.tripmate.backend.schedule.dto.ScheduleResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api")
public class ScheduleController {

    private final ScheduleService scheduleService;
    private final AuthUserIdResolver authUserIdResolver;

    public ScheduleController(
            ScheduleService scheduleService,
            AuthUserIdResolver authUserIdResolver
    ) {
        this.scheduleService = scheduleService;
        this.authUserIdResolver = authUserIdResolver;
    }

    @GetMapping("/trips/{tripId}/schedules")
    public ResponseEntity<List<ScheduleResponse>> getSchedules(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(scheduleService.getSchedules(tripId, userId));
    }

    @PostMapping("/trips/{tripId}/schedules")
    public ResponseEntity<ScheduleResponse> createSchedule(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody ScheduleRequest request
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(scheduleService.createSchedule(tripId, userId, request));
    }

    @PostMapping("/trips/{tripId}/schedules/import")
    public ResponseEntity<ScheduleService.ImportResult> importSchedule(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody ScheduleRequest request
    ) {
        var result = scheduleService.importSchedule(tripId, authUserIdResolver.resolve(authorizationHeader), request);
        return ResponseEntity.status(result.created() ? HttpStatus.CREATED : HttpStatus.OK).body(result);
    }

    @PatchMapping("/schedules/{scheduleId}")
    public ResponseEntity<ScheduleResponse> updateSchedule(
            @PathVariable Long scheduleId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody ScheduleRequest request
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(scheduleService.updateSchedule(scheduleId, userId, request));
    }

    @DeleteMapping("/schedules/{scheduleId}")
    public ResponseEntity<Void> deleteSchedule(
            @PathVariable Long scheduleId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);
        scheduleService.deleteSchedule(scheduleId, userId);

        return ResponseEntity.noContent().build();
    }
}
