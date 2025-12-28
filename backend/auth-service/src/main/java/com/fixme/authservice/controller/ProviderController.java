package com.fixme.authservice.controller;

import com.fixme.authservice.dto.ProviderBusinessRequest;
import com.fixme.authservice.dto.ProviderBusinessResponse;
import com.fixme.authservice.service.ProviderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // عشان Flutter
public class ProviderController {

    private final ProviderService providerService;

    @PostMapping("/{userId}/business")
    public ResponseEntity<ProviderBusinessResponse> saveBusiness(
            @PathVariable Long userId,
            @RequestBody ProviderBusinessRequest request
    ) {
        ProviderBusinessResponse response = providerService.createOrUpdateBusiness(userId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{userId}/business")
    public ResponseEntity<ProviderBusinessResponse> getBusiness(
            @PathVariable Long userId
    ) {
        ProviderBusinessResponse response = providerService.getBusiness(userId);
        return ResponseEntity.ok(response);
    }
}
