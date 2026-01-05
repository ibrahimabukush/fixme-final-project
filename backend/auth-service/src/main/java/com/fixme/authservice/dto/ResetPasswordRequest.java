package com.fixme.authservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ResetPasswordRequest {
    @NotBlank
    private String identifier; // email or phone

    @NotBlank
    private String tokenCode; // 6-digit code

    @NotBlank
    private String newPassword;

    @NotBlank
    private String confirmPassword;
}
