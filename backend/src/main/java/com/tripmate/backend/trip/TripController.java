package com.tripmate.backend.trip;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.trip.dto.CreateTripRequest;
import com.tripmate.backend.trip.dto.TripResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/trips")
public class TripController {

    private final TripService tripService;
    private final AuthUserIdResolver authUserIdResolver;

    public TripController(
            TripService tripService,
            AuthUserIdResolver authUserIdResolver
    ) {
        this.tripService = tripService;
        this.authUserIdResolver = authUserIdResolver;
    }

    @GetMapping
    public ResponseEntity<List<TripResponse>> getTrips(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(tripService.getTrips(userId));
    }

    @PostMapping
    public ResponseEntity<TripResponse> createTrip(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody CreateTripRequest request
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);
        TripResponse response = tripService.createTrip(userId, request);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
