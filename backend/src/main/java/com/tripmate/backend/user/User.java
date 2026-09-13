package com.tripmate.backend.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity 
@Table(name = "users")
@Getter 
@NoArgsConstructor 
public class User {
    
    @Id
    @GeneratedValue (strategy = GenerationType.IDENTITY)
    private Long id;

    @Column (nullable = false, unique = true, length = 100)
    private String email;

    @Column (nullable = false, length = 255)
    private String password;

    @Column (nullable = false, length = 50)
    private String nickname;

    @Column (nullable = false)
    private LocalDateTime createdAt;

    @Column (nullable = false)
    private LocalDateTime updatedAt;

    public User(String email, String password, String nickname) {
        this.email = email;
        this.password = password;
        this.nickname = nickname;
    }

    @PrePersist 
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate 
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

}
