package com.tripmate.backend.schedule;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    @Query("""
            select s
            from Schedule s
            join fetch s.trip t
            where t.id = :tripId
            order by s.scheduledDate asc, s.scheduledTime asc, s.sortOrder asc, s.id asc
            """)
    List<Schedule> findByTripIdOrderBySchedule(
            @Param("tripId") Long tripId
    );
}
