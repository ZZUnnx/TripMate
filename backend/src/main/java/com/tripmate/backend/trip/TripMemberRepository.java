package com.tripmate.backend.trip;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TripMemberRepository extends JpaRepository<TripMember, Long> {

    long countByTrip_Id(Long tripId);

    boolean existsByTrip_IdAndUser_Id(Long tripId, Long userId);

    @Query("""
            select tm
            from TripMember tm
            join fetch tm.user
            where tm.trip.id = :tripId
            order by tm.joinedAt asc
            """)
    List<TripMember> findByTrip_IdOrderByJoinedAtAsc(@Param("tripId") Long tripId);
}
