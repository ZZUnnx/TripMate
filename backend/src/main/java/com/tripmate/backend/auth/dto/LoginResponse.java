package com.tripmate.backend.auth.dto;

public record LoginResponse(
    Long id,
    String email,
    String nickname
) {
}