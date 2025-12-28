package com.fixme.authservice.dto;

import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.model.VerificationType;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignupRequest {

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @Email
    @NotBlank
    private String email;

    @NotBlank
    @Pattern(
            regexp = "^(05\\d{8}|\\+9725\\d{8})$",
            message = "Phone must be Israeli mobile number"
    )
    private String phone;

    @NotBlank
    @Pattern(
            regexp = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$",
            message = "Password must be >= 8 chars, with upper, lower & digit"
    )
    private String password;

    @NotBlank
    private String confirmPassword;

    @NotNull
    private UserRole role; // CUSTOMER or PROVIDER

    @NotNull
    private VerificationType verificationType; // EMAIL or PHONE
}
