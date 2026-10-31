package com.tripmate.backend.settlement;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public record ExpenseRequest(
        @NotBlank @Size(max = 100) String title,
        @NotNull @Min(1) @Max(1000000000000L) Long amount,
        @NotNull Long payerId,
        @Size(max = 100) String placeName,
        @NotNull LocalDate expenseDate,
        @NotEmpty List<@NotNull Long> participantIds
) {}
