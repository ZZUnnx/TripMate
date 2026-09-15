package com.tripmate.backend.trip;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TripMemberRepository extends JpaRepository<TripMember, Long> {

    long countByTrip_Id(Long tripId);
}
