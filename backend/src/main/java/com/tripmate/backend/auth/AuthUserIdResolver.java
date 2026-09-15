package com.tripmate.backend.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AuthUserIdResolver {

    private final JwtUtil jwtUtil;

    public AuthUserIdResolver(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    public Long resolve(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "로그인이 필요합니다."
            );
        }

        String token = authorizationHeader.substring("Bearer ".length());

        try {
            Claims claims = jwtUtil.parseToken(token);
            Object userId = claims.get("userId");

            if (userId instanceof Number number) {
                return number.longValue();
            }

            return Long.parseLong(String.valueOf(userId));
        } catch (JwtException | IllegalArgumentException e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "유효하지 않은 토큰입니다."
            );
        }
    }
}
