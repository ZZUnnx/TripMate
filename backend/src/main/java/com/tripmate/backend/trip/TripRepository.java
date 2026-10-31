package com.tripmate.backend.trip;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TripRepository extends JpaRepository<Trip, Long> {

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from Trip t where t.id = :tripId")
    Optional<Trip> findByIdForUpdate(@Param("tripId") Long tripId);

    @Query("""
            select distinct t
            from Trip t
            left join fetch t.owner
            left join TripMember tm on tm.trip = t and tm.user.id = :userId
            where t.owner.id = :userId
               or tm.id is not null
            """)
    List<Trip> findChatRoomsByUserId(@Param("userId") Long userId);

    @Query("""
            select distinct t
            from Trip t
            left join fetch t.owner
            left join TripMember tm on tm.trip = t and tm.user.id = :userId
            where t.id = :tripId
              and (
                t.owner.id = :userId
                or tm.id is not null
              )
            """)
    Optional<Trip> findAccessibleChatRoom(
            @Param("tripId") Long tripId,
            @Param("userId") Long userId
    );
}
