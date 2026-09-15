package com.tripmate.backend.trip.dto;

import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.trip.TripMember;
import com.tripmate.backend.user.User;

import java.time.LocalDateTime;

public record TripMemberResponse(
        Long userId,
        String email,
        String nickname,
        String role,
        boolean owner,
        LocalDateTime joinedAt
) {
    public static TripMemberResponse owner(Trip trip) {
        User owner = trip.getOwner();

        return new TripMemberResponse(
                owner.getId(),
                owner.getEmail(),
                owner.getNickname(),
                "OWNER",
                true,
                trip.getCreatedAt()
        );
    }

    public static TripMemberResponse member(TripMember tripMember) {
        User user = tripMember.getUser();

        return new TripMemberResponse(
                user.getId(),
                user.getEmail(),
                user.getNickname(),
                tripMember.getRole(),
                false,
                tripMember.getJoinedAt()
        );
    }
}
