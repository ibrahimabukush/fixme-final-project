package com.fixme.authservice.dto;
import lombok.*;
import com.fixme.authservice.model.User;
import jakarta.validation.constraints.Pattern;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfileDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    @Pattern(regexp = "^05\\d{8}$", message = "Phone must be Israeli mobile (05XXXXXXXX)")
    private String phone;
    private String role;
    private String profileImageUrl; // 👈 جديد

    public static UserProfileDto fromEntity(User user) {
        return UserProfileDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole().name())
                .profileImageUrl(user.getProfileImageUrl())
                .build();
    }
}
