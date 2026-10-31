package com.tripmate.backend.settlement;

import com.tripmate.backend.auth.AuthUserIdResolver;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SettlementController {
    private final SettlementService service;
    private final AuthUserIdResolver auth;

    public SettlementController(SettlementService service, AuthUserIdResolver auth) { this.service = service; this.auth = auth; }
    public record CompletionRequest(@NotNull Boolean completed) {}

    @GetMapping("/settlements")
    public List<SettlementResponse> list(@RequestHeader(value = "Authorization", required = false) String header) {
        return service.list(auth.resolve(header));
    }

    @GetMapping("/trips/{tripId}/settlement")
    public SettlementResponse get(@PathVariable Long tripId, @RequestHeader(value = "Authorization", required = false) String header) {
        return service.get(tripId, auth.resolve(header));
    }

    @PostMapping("/trips/{tripId}/expenses")
    public ResponseEntity<Void> create(@PathVariable Long tripId, @RequestHeader(value = "Authorization", required = false) String header,
                                       @Valid @RequestBody ExpenseRequest request) {
        service.create(tripId, auth.resolve(header), request);
        return ResponseEntity.status(201).build();
    }

    @PatchMapping("/expenses/{expenseId}")
    public ResponseEntity<Void> update(@PathVariable Long expenseId, @RequestHeader(value = "Authorization", required = false) String header,
                                       @Valid @RequestBody ExpenseRequest request) {
        service.update(expenseId, auth.resolve(header), request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/expenses/{expenseId}")
    public ResponseEntity<Void> delete(@PathVariable Long expenseId, @RequestHeader(value = "Authorization", required = false) String header) {
        service.delete(expenseId, auth.resolve(header));
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/trips/{tripId}/settlement")
    public ResponseEntity<Void> complete(@PathVariable Long tripId, @RequestHeader(value = "Authorization", required = false) String header,
                                         @Valid @RequestBody CompletionRequest request) {
        service.complete(tripId, auth.resolve(header), request.completed());
        return ResponseEntity.noContent().build();
    }
}
