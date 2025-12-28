package com.fixme.authservice.dto;

import lombok.Data;

@Data
public class ProviderBusinessRequest {

    private String businessName;
    private String city;
    private String address;
    private String description;
    private String services;      // نص بسيط: "Towing, Tires, Garage"
    private String openingHours;  // "Sun-Thu 09:00-18:00"
}
