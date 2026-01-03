package com.fixme.authservice.controller;

import com.fixme.authservice.dto.*;
import com.fixme.authservice.model.ServiceType;
import com.fixme.authservice.model.Vehicle;
import com.fixme.authservice.model.VehicleCategory;
import com.fixme.authservice.service.CustomerNearbyProviderService;
import com.fixme.authservice.service.CustomerRequestService;
import com.fixme.authservice.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;
    private final CustomerRequestService customerRequestService;
    private final CustomerNearbyProviderService customerNearbyProviderService;

    // إضافة سيارة جديدة
    @PostMapping("/{userId}/vehicles")
    public ResponseEntity<VehicleResponse> addVehicle(
            @PathVariable Long userId,
            @Valid @RequestBody VehicleRequest request
    ) {
        Vehicle v = customerService.addVehicle(userId, request);

        VehicleResponse response = new VehicleResponse(
                v.getId(),
                v.getPlateNumber(),
                v.getMake(),
                v.getModel(),
                v.getYear(),
                v.getVehicleCategory()
        );

        return ResponseEntity.ok(response);
    }

    // تحديث سيارة
    @PutMapping("/{userId}/vehicles/{vehicleId}")
    public ResponseEntity<VehicleResponse> updateVehicle(
            @PathVariable Long userId,
            @PathVariable Long vehicleId,
            @Valid @RequestBody VehicleRequest request
    ) {
        Vehicle v = customerService.updateVehicle(userId, vehicleId, request);

        VehicleResponse response = new VehicleResponse(
                v.getId(),
                v.getPlateNumber(),
                v.getMake(),
                v.getModel(),
                v.getYear(),
                v.getVehicleCategory()
        );

        return ResponseEntity.ok(response);
    }

    // حذف سيارة
    @DeleteMapping("/{userId}/vehicles/{vehicleId}")
    public ResponseEntity<Void> deleteVehicle(
            @PathVariable Long userId,
            @PathVariable Long vehicleId
    ) {
        customerService.deleteVehicle(userId, vehicleId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{userId}/providers/nearby")
    public List<NearbyProviderResponse> nearbyProviders(
            @PathVariable Long userId,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "10") double radiusKm,
            @RequestParam VehicleCategory category,
            @RequestParam ServiceType serviceType
    ) {
        return customerNearbyProviderService.nearbyProviders(lat, lng, radiusKm, category, serviceType);
    }


    // إنشاء request (PENDING, بدون provider)
    @PostMapping("/{userId}/requests")
    public ResponseEntity<ServiceRequestResponse> createRequest(
            @PathVariable Long userId,
            @Valid @RequestBody ServiceRequestCreateRequest request
    ) {
        return ResponseEntity.ok(customerRequestService.createRequest(userId, request));
    }

    // ✅ جديد: ربط request مع provider (PENDING -> WAITING_PROVIDER)
    @PostMapping("/{userId}/requests/{requestId}/assign/{providerId}")
    public ServiceRequestResponse assignProvider(
            @PathVariable Long userId,
            @PathVariable Long requestId,
            @PathVariable Long providerId
    ) {
        return customerRequestService.assignProvider(userId, requestId, providerId);
    }

    // جلب طلبات العميل
    @GetMapping("/{userId}/requests")
    public List<ServiceRequestResponse> myRequests(@PathVariable Long userId) {
        return customerRequestService.getMyRequests(userId);
    }

    // جلب سيارات العميل
    @GetMapping("/{userId}/vehicles")
    public List<VehicleResponse> getVehicles(@PathVariable Long userId) {
        return customerService.getVehicles(userId)
                .stream()
                .map(v -> new VehicleResponse(
                        v.getId(),
                        v.getPlateNumber(),
                        v.getMake(),
                        v.getModel(),
                        v.getYear(),
                        v.getVehicleCategory()
                ))
                .toList();
    }

    // تأكيد الطلب
    @PostMapping("/{userId}/requests/{requestId}/confirm")
    public ServiceRequestResponse confirm(
            @PathVariable Long userId,
            @PathVariable Long requestId
    ) {
        return customerRequestService.confirm(userId, requestId);
    }
}
