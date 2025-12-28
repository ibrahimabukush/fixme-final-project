package com.fixme.authservice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ProviderBusinessResponse {

    private Long id;
    private Long userId;
    private String businessName;
    private String city;
    private String address;
    private String description;
    private String services;
    private String openingHours;
}
