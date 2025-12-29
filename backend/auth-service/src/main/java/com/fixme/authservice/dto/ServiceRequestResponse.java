package com.fixme.authservice.dto;

import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.model.VehicleCategory;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class ServiceRequestResponse {
    private Long id;

    private Long vehicleId;
    private String plateNumber;
    private String make;
    private String model;
    private Integer year;

    private VehicleCategory vehicleCategory;

    private Double latitude;
    private Double longitude;

    private RequestStatus status;
    private LocalDateTime createdAt;
}
