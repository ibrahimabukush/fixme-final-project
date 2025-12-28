package com.fixme.authservice.service;

import com.fixme.authservice.dto.UserProfileDto;
import com.fixme.authservice.model.User;
import com.fixme.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Service
@RequiredArgsConstructor
public class ProfileImageService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    private final UserRepository userRepository;

    public UserProfileDto uploadProfileImage(Long userId, MultipartFile file) throws IOException {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // نتأكد إن فولدر الرفع موجود
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // نعمل اسم ملف مرتب
        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = "user_" + userId + "_avatar" + ext;

        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // نخزّن الرابط في الـ DB
        String url = "/uploads/" + fileName;
        user.setProfileImageUrl(url);
        userRepository.save(user);

        return UserProfileDto.fromEntity(user);
    }
}
