package com.tripmate.backend.trip;

import com.tripmate.backend.trip.dto.AddTripMemberRequest;
import com.tripmate.backend.trip.dto.TripMemberResponse;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;

@Service
public class TripMemberService {

    private final TripRepository tripRepository;
    private final TripMemberRepository tripMemberRepository;
    private final UserRepository userRepository;

    public TripMemberService(
            TripRepository tripRepository,
            TripMemberRepository tripMemberRepository,
            UserRepository userRepository
    ) {
        this.tripRepository = tripRepository;
        this.tripMemberRepository = tripMemberRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<TripMemberResponse> getMembers(Long tripId, Long userId) {
        Trip trip = findAccessibleTrip(tripId, userId);
        List<TripMemberResponse> members = new ArrayList<>();

        members.add(TripMemberResponse.owner(trip));
        members.addAll(
                tripMemberRepository.findByTrip_IdOrderByJoinedAtAsc(tripId)
                        .stream()
                        .map(TripMemberResponse::member)
                        .toList()
        );

        return members;
    }

    @Transactional
    public TripMemberResponse addMember(
            Long tripId,
            Long userId,
            AddTripMemberRequest request
    ) {
        Trip trip = findAccessibleTrip(tripId, userId);
        User member = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "초대할 사용자를 찾을 수 없습니다."
                ));

        if (trip.getOwner().getId().equals(member.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "여행방 생성자는 이미 참여 중입니다."
            );
        }

        if (tripMemberRepository.existsByTrip_IdAndUser_Id(tripId, member.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "이미 참여 중인 사용자입니다."
            );
        }

        String role = normalizeRole(request.role());
        TripMember tripMember = new TripMember(trip, member, role);

        return TripMemberResponse.member(tripMemberRepository.save(tripMember));
    }

    private Trip findAccessibleTrip(Long tripId, Long userId) {
        return tripRepository.findAccessibleChatRoom(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "여행방을 찾을 수 없습니다."
                ));
    }

    private String normalizeRole(String role) {
        if (role == null || role.isBlank()) {
            return "MEMBER";
        }

        return role.trim().toUpperCase();
    }
}
