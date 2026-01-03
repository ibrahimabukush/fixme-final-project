package com.fixme.authservice.dto;

import com.fixme.authservice.model.ServiceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ServiceRequestCreateRequest {


    @NotNull
    private Long vehicleId;

    @NotBlank
    private String description;

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;
    @NotNull
    private ServiceType serviceType;
}

