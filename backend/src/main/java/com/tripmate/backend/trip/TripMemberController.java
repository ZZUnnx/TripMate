package com.tripmate.backend.trip;

import com.tripmate.backend.auth.AuthUserIdResolver;
import com.tripmate.backend.trip.dto.AddTripMemberRequest;
import com.tripmate.backend.trip.dto.TripMemberResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/trips/{tripId}/members")
public class TripMemberController {

    private final TripMemberService tripMemberService;
    private final AuthUserIdResolver authUserIdResolver;

    public TripMemberController(
            TripMemberService tripMemberService,
            AuthUserIdResolver authUserIdResolver
    ) {
        this.tripMemberService = tripMemberService;
        this.authUserIdResolver = authUserIdResolver;
    }

    @GetMapping
    public ResponseEntity<List<TripMemberResponse>> getMembers(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);

        return ResponseEntity.ok(tripMemberService.getMembers(tripId, userId));
    }

    @PostMapping
    public ResponseEntity<TripMemberResponse> addMember(
            @PathVariable Long tripId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody AddTripMemberRequest request
    ) {
        Long userId = authUserIdResolver.resolve(authorizationHeader);
        TripMemberResponse response = tripMemberService.addMember(
                tripId,
                userId,
                request
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
