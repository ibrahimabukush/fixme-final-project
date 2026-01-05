package com.fixme.authservice.dto;

import com.fixme.authservice.model.VerificationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ForgotPasswordRequest {
    @NotBlank
    private String identifier; // email or phone

    @NotNull
    private VerificationType verificationType; // EMAIL / PHONE
}
