package com.fixme.authservice.dto;

import com.fixme.authservice.model.VerificationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResendVerificationRequest {
    @NotBlank
    private String identifier; // email or phone

    @NotNull
    private VerificationType verificationType; // EMAIL or PHONE
}
