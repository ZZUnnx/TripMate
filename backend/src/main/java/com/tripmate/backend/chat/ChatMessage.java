package com.tripmate.backend.chat;

import com.tripmate.backend.trip.Trip;
import com.tripmate.backend.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
@Getter
@NoArgsConstructor
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 어느 여행방의 메시지인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    // 누가 보낸 메시지인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;

    // 채팅 내용
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    // 메시지를 보낸 시간
    @Column(nullable = false)
    private LocalDateTime sentAt;

    @PrePersist
    public void prePersist() {
        this.sentAt = LocalDateTime.now();
    }
}