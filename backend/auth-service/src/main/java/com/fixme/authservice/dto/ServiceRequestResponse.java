package com.fixme.authservice.dto;

import com.fixme.authservice.model.ProgressStage;
import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.model.ServiceType;
import com.fixme.authservice.model.VehicleCategory;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class ServiceRequestResponse {
    private Long id;

    private Long customerId;
    private Long providerId;

    private Long vehicleId;
    private String plateNumber;
    private String make;
    private String model;
    private Integer year;

    private String description;

    private VehicleCategory vehicleCategory;
    private ServiceType serviceType;

    private Double latitude;
    private Double longitude;

    private RequestStatus status;
    private ProgressStage progressStage;
    private LocalDateTime createdAt;
}
