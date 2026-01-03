package com.fixme.authservice.dto;

import com.fixme.authservice.model.ServiceType;
import com.fixme.authservice.model.VehicleCategory;
import lombok.Builder;
import lombok.Data;

import java.util.Set;

@Data
@Builder
public class NearbyProviderResponse {
    private Long userId;
    private Long businessId;
    private String businessName;
    private String description;
    private String services;
    private Set<ServiceType> offeredServices;
    private String openingHours;
    private Double latitude;
    private Double longitude;
    private Set<VehicleCategory> categories;
    private Double distanceKm;
}
