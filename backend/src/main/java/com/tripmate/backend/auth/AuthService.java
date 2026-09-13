package com.tripmate.backend.auth;

import com.tripmate.backend.auth.dto.SignupRequest;
import com.tripmate.backend.user.User;
import com.tripmate.backend.user.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.tripmate.backend.auth.dto.LoginRequest;
import com.tripmate.backend.auth.dto.LoginResponse;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
        UserRepository userRepository,
        PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void signup(SignupRequest request) {

        // 이메일 중복 확인
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }

        // 사용자 생성
        User user = new User(
                request.email(),
                passwordEncoder.encode(request.password()),
                request.nickname()
        );

        // DB 저장
        userRepository.save(user);
    }

    public LoginResponse login(LoginRequest request) {

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() ->
                        new IllegalArgumentException("이메일 또는 비밀번호가 올바르지 않습니다.")
                );
    
        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new IllegalArgumentException(
                    "이메일 또는 비밀번호가 올바르지 않습니다."
            );
        }
    
        return new LoginResponse(
                user.getId(),
                user.getEmail(),
                user.getNickname()
        );
    }
}