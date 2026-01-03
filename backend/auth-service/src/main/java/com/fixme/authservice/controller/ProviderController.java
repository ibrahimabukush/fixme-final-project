package com.fixme.authservice.controller;

import com.fixme.authservice.dto.NearbyRequestResponse;
import com.fixme.authservice.dto.ProviderBusinessRequest;
import com.fixme.authservice.dto.ProviderBusinessResponse;
import com.fixme.authservice.dto.ServiceRequestResponse;
import com.fixme.authservice.model.ProgressStage;
import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.service.ProviderRequestService;
import com.fixme.authservice.service.ProviderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProviderController {

    private final ProviderService providerService;
    private final ProviderRequestService providerRequestService;

    @PostMapping("/{userId}/business")
    public ResponseEntity<ProviderBusinessResponse> saveBusiness(
            @PathVariable Long userId,
            @RequestBody ProviderBusinessRequest request
    ) {
        ProviderBusinessResponse response = providerService.createOrUpdateBusiness(userId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{userId}/business")
    public ResponseEntity<ProviderBusinessResponse> getBusiness(@PathVariable Long userId) {
        ProviderBusinessResponse response = providerService.getBusiness(userId);
        return ResponseEntity.ok(response);
    }

    // nearby requests (PENDING around provider)
    @GetMapping("/{userId}/requests/nearby")
    public ResponseEntity<List<NearbyRequestResponse>> nearbyRequests(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "10") double radiusKm
    ) {
        return ResponseEntity.ok(providerRequestService.nearby(userId, radiusKm));
    }

    // inbox: assigned requests
    @GetMapping("/{providerId}/requests")
    public List<ServiceRequestResponse> inbox(
            @PathVariable Long providerId,
            @RequestParam(required = false) RequestStatus status
    ) {
        return providerRequestService.inbox(providerId, status);
    }

    // accept: WAITING_PROVIDER -> WAITING_CUSTOMER
    @PostMapping("/{providerId}/requests/{requestId}/accept")
    public ServiceRequestResponse accept(
            @PathVariable Long providerId,
            @PathVariable Long requestId
    ) {
        return providerRequestService.accept(providerId, requestId);
    }

    // ✅ NEW: confirmed jobs (customer confirmed => ACCEPTED)
    @GetMapping("/{providerId}/jobs/confirmed")
    public List<ServiceRequestResponse> confirmedJobs(@PathVariable Long providerId) {
        return providerRequestService.confirmedJobs(providerId);
    }

    // ✅ NEW: update progress stage
    @PatchMapping("/{providerId}/requests/{requestId}/progress")
    public ServiceRequestResponse updateProgress(
            @PathVariable Long providerId,
            @PathVariable Long requestId,
            @RequestParam ProgressStage stage
    ) {
        return providerRequestService.updateProgress(providerId, requestId, stage);
    }
}
