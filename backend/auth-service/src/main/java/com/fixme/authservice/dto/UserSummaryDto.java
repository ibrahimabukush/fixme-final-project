package com.fixme.authservice.dto;

import com.fixme.authservice.model.ProviderApprovalStatus;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserSummaryDto {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean verified;
    private UserRole role;
    private ProviderApprovalStatus providerApprovalStatus;
    private LocalDateTime createdAt;

    public static UserSummaryDto fromEntity(User user) {
        return UserSummaryDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .verified(user.isVerified())
                .role(user.getRole())
                .providerApprovalStatus(user.getProviderApprovalStatus())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
