package com.tripmate.backend.chat;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    Optional<ChatMessage> findFirstByTrip_IdOrderBySentAtDesc(Long tripId);

    List<ChatMessage> findByTrip_IdOrderBySentAtAsc(Long tripId);
}
