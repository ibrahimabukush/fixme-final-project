package com.fixme.authservice.dto;

import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.model.VehicleCategory;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class NearbyRequestResponse {
    private Long id;

    private Long customerId;
    private Long vehicleId;

    private String plateNumber;
    private String make;
    private String model;
    private Integer year;

    private String description;
    private VehicleCategory vehicleCategory;

    private Double latitude;
    private Double longitude;

    private Double distanceKm;

    private RequestStatus status;
    private LocalDateTime createdAt;
}
