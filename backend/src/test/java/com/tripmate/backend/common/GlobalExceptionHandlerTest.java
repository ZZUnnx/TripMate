package com.tripmate.backend.common;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class GlobalExceptionHandlerTest {
    private final MockMvc mvc = MockMvcBuilders.standaloneSetup(new ErrorController())
            .setControllerAdvice(new GlobalExceptionHandler()).build();

    @RestController
    static class ErrorController {
        @GetMapping("/duplicate")
        void duplicate() {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }

        @GetMapping("/forbidden")
        void forbidden() {
            throw new SecurityException("Internal permission details");
        }

        @GetMapping("/status/{status}")
        void status(@PathVariable int status) {
            throw new ResponseStatusException(HttpStatus.valueOf(status), "Request rejected");
        }

        record Input(@NotBlank String name) {}

        @PostMapping("/input")
        void input(@Valid @RequestBody Input input) {}

        @GetMapping("/parameter")
        void parameter(@RequestParam Long tripId) {}
    }

    @Test
    void duplicateEmailReturnsBadRequestWithConsistentJson() throws Exception {
        mvc.perform(get("/duplicate"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.error").value("Bad Request"))
                .andExpect(jsonPath("$.message").value("이미 사용 중인 이메일입니다."))
                .andExpect(jsonPath("$.path").value("/duplicate"));
    }

    @Test
    void permissionDeniedReturnsForbiddenWithoutInternalDetails() throws Exception {
        mvc.perform(get("/forbidden"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.status").value(403))
                .andExpect(jsonPath("$.error").value("Forbidden"))
                .andExpect(jsonPath("$.message").value("접근 권한이 없습니다."))
                .andExpect(jsonPath("$.path").value("/forbidden"));
    }

    @Test
    void explicitStatusesArePreservedAndUseSameJson() throws Exception {
        for (int status : new int[]{400, 401, 403, 404}) {
            mvc.perform(get("/status/" + status))
                    .andExpect(status().is(status))
                    .andExpect(jsonPath("$.status").value(status))
                    .andExpect(jsonPath("$.message").value("Request rejected"))
                    .andExpect(jsonPath("$.path").value("/status/" + status));
        }
    }

    @Test
    void invalidDtoAndMalformedJsonReturnSameBadRequestShape() throws Exception {
        for (String body : new String[]{"{\"name\":\"\"}", "{"}) {
            mvc.perform(post("/input").contentType(MediaType.APPLICATION_JSON).content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.status").value(400))
                    .andExpect(jsonPath("$.error").value("Bad Request"))
                    .andExpect(jsonPath("$.message").value("요청 입력값이 올바르지 않습니다."))
                    .andExpect(jsonPath("$.path").value("/input"));
        }
    }

    @Test
    void missingAndInvalidParametersReturnBadRequestJson() throws Exception {
        mvc.perform(get("/parameter"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
        mvc.perform(get("/parameter").param("tripId", "invalid"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }
}
