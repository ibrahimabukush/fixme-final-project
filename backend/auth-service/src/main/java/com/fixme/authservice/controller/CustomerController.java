package com.fixme.authservice.controller;

import com.fixme.authservice.dto.ServiceRequestCreateRequest;
import com.fixme.authservice.dto.ServiceRequestResponse;
import com.fixme.authservice.dto.VehicleRequest;
import com.fixme.authservice.dto.VehicleResponse;
import com.fixme.authservice.model.Vehicle;
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

    // إضافة سيارة جديدة لعميل (userId هو ID من جدول users)
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
    @DeleteMapping("/{userId}/vehicles/{vehicleId}")
    public ResponseEntity<Void> deleteVehicle(
            @PathVariable Long userId,
            @PathVariable Long vehicleId
    ) {
        customerService.deleteVehicle(userId, vehicleId);
        return ResponseEntity.noContent().build();
    }
    @PostMapping("/{userId}/requests")
    public ResponseEntity<ServiceRequestResponse> createRequest(
            @PathVariable Long userId,
            @Valid @RequestBody ServiceRequestCreateRequest request
    ) {
        return ResponseEntity.ok(customerRequestService.createRequest(userId, request));
    }

    @GetMapping("/{userId}/requests")
    public List<ServiceRequestResponse> myRequests(@PathVariable Long userId) {
        return customerRequestService.getMyRequests(userId);
    }


    // جلب سيارات العميل (لاحقاً نستعملها في الـ profile)
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
}
