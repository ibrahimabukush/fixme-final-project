package com.fixme.authservice.dto;

import com.fixme.authservice.model.ServiceType;
import com.fixme.authservice.model.VehicleCategory;
import lombok.Data;

import java.util.Set;

@Data
public class ProviderBusinessRequest {

    private String businessName;
    private String city;
    private String address;
    private String description;
    private String services;      // "Towing, Tires, Garage"
    private String openingHours;  // "Sun-Thu 09:00-18:00"
    private Double latitude;
    private Double longitude;
    private java.util.Set<VehicleCategory> categories;
    private Set<ServiceType> offeredServices;



}
