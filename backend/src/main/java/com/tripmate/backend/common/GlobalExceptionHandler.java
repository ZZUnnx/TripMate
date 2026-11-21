package com.tripmate.backend.common;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    public record ApiError(int status, String error, String message, String path) {}

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Object> handleIllegalArgument(IllegalArgumentException exception, WebRequest request) {
        return error(HttpStatus.BAD_REQUEST, exception.getMessage(), new HttpHeaders(), request);
    }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<Object> handleForbidden(SecurityException exception, WebRequest request) {
        return error(HttpStatus.FORBIDDEN, "접근 권한이 없습니다.", new HttpHeaders(), request);
    }

    @Override
    protected ResponseEntity<Object> handleExceptionInternal(
            Exception exception, Object body, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        String message;
        if (exception instanceof ResponseStatusException responseStatusException) {
            message = responseStatusException.getReason();
        } else if (status.value() == 400) {
            message = "요청 입력값이 올바르지 않습니다.";
        } else {
            HttpStatus knownStatus = HttpStatus.resolve(status.value());
            message = knownStatus == null ? "요청을 처리할 수 없습니다." : knownStatus.getReasonPhrase();
        }
        return error(status, message, headers, request);
    }

    private ResponseEntity<Object> error(
            HttpStatusCode status, String message, HttpHeaders headers, WebRequest request) {
        HttpStatus knownStatus = HttpStatus.resolve(status.value());
        String reason = knownStatus == null ? "HTTP Error" : knownStatus.getReasonPhrase();
        String path = request instanceof ServletWebRequest servletRequest
                ? servletRequest.getRequest().getRequestURI() : "";
        ApiError body = new ApiError(status.value(), reason,
                message == null || message.isBlank() ? reason : message, path);
        return new ResponseEntity<>(body, headers, status);
    }
}
