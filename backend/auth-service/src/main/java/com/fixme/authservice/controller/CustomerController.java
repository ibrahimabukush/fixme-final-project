package com.fixme.authservice.controller;

import com.fixme.authservice.dto.VehicleRequest;
import com.fixme.authservice.dto.VehicleResponse;
import com.fixme.authservice.model.Vehicle;
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
                v.getYear()
        );

        return ResponseEntity.ok(response);
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
                        v.getYear()
                ))
                .toList();
    }
}
