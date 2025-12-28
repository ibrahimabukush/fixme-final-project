package com.fixme.authservice.dto;

import com.fixme.authservice.model.ProviderApprovalStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PendingProviderDto {

    // معلومات الـ user نفسه
    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean verified;
    private ProviderApprovalStatus providerApprovalStatus;

    // معلومات البزنس (من جدول provider_business)
    private String businessName;
    private String city;
    private String address;
    private String description;
    private String services;
    private String openingHours;
}
