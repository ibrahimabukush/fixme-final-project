package com.fixme.authservice.controller;

import com.fixme.authservice.model.User;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.service.ProfileImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import com.fixme.authservice.dto.UserProfileDto;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;


@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")


public class ProfileController {

    private final UserRepository userRepository;
    private final ProfileImageService profileImageService;

    // 1) جلب بروفايل مستخدم معيّن
    @GetMapping("/{userId}")
    public ResponseEntity<UserProfileDto> getProfile(@PathVariable Long userId) {
        return userRepository.findById(userId)
                .map(UserProfileDto::fromEntity)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 2) تحديث بيانات البروفايل (بدون الصورة)
    @PutMapping("/{userId}")
    public ResponseEntity<UserProfileDto> updateProfile(
            @PathVariable Long userId,
            @RequestBody UserProfileDto dto
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setPhone(dto.getPhone());
        userRepository.save(user);

        return ResponseEntity.ok(UserProfileDto.fromEntity(user));
    }

    // 3) رفع صورة بروفايل
    @PostMapping(
            value = "/{userId}/avatar",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<UserProfileDto> uploadAvatar(
            @PathVariable Long userId,
            @RequestPart("file") MultipartFile file
    ) throws IOException {
        UserProfileDto dto = profileImageService.uploadProfileImage(userId, file);
        return ResponseEntity.ok(dto);
    }
}