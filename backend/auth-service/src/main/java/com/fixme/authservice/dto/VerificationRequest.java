package com.fixme.authservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VerificationRequest {

    @NotBlank
    private String tokenCode; // الكود اللي نبعته بالمستقبل بالايميل أو SMS
}
