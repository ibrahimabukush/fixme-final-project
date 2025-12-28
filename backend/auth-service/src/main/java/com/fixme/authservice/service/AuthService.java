package com.fixme.authservice.service;

import com.fixme.authservice.dto.LoginRequest;
import com.fixme.authservice.dto.LoginResponse;
import com.fixme.authservice.dto.SignupRequest;
import com.fixme.authservice.dto.VerificationRequest;
import com.fixme.authservice.model.*;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.repository.VerificationTokenRepository;
import com.fixme.authservice.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class AuthService {

    // أداة صغيرة لتوليد BCRYPT للـ admin لو احتجته
    public static class PasswordHashGenerator {
        public static void main(String[] args) {
            PasswordEncoder encoder = new BCryptPasswordEncoder();
            String rawPassword = "Admin1234!";
            String hash = encoder.encode(rawPassword);
            System.out.println("BCRYPT = " + hash);
        }
    }

    private final UserRepository userRepository;
    private final VerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final Optional<SmsService> smsService;
    private final JwtUtil jwtUtil;

    @Transactional
    public void signup(SignupRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Passwords do not match");
        }

        userRepository.findByEmail(request.getEmail())
                .ifPresent(u -> { throw new IllegalArgumentException("Email already in use"); });

        userRepository.findByPhone(request.getPhone())
                .ifPresent(u -> { throw new IllegalArgumentException("Phone already in use"); });

        ProviderApprovalStatus providerStatus =
                request.getRole() == UserRole.PROVIDER
                        ? ProviderApprovalStatus.PENDING
                        : ProviderApprovalStatus.NOT_PROVIDER;

        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .verified(false)
                .providerApprovalStatus(providerStatus)
                .createdAt(LocalDateTime.now())
                .build();

        userRepository.save(user);

        String tokenCode = generateVerificationCode();
        VerificationToken token = VerificationToken.builder()
                .user(user)
                .tokenCode(tokenCode)
                .type(request.getVerificationType()) // EMAIL / PHONE
                .used(false)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusMinutes(15))
                .build();

        tokenRepository.save(token);

        if (token.getType() == VerificationType.EMAIL) {
            emailService.sendVerificationCode(user.getEmail(), tokenCode);
        } else if (token.getType() == VerificationType.PHONE) {
            System.out.println("DEV MODE: SMS code for " + user.getPhone() + " = " + tokenCode);
        }

        System.out.println("VERIFICATION CODE for user " + user.getEmail() + " = " + tokenCode);
    }


    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByPhone(request.getIdentifier()))
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        if (!user.isVerified()) {
            throw new IllegalStateException("User not verified");
        }

        // 👇 رجّعنا شرط الـ provider approved بعد ما عملت شاشة الأدمن
        if (user.getRole() == UserRole.PROVIDER &&
                user.getProviderApprovalStatus() != ProviderApprovalStatus.APPROVED) {
            throw new IllegalStateException("Provider not approved yet");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getId(), user.getRole());

        return new LoginResponse(
                user.getId(),
                user.getRole().name(),
                token
        );
    }

    @Transactional
    public void verify(VerificationRequest request) {
        VerificationToken token = tokenRepository.findByTokenCode(request.getTokenCode())
                .orElseThrow(() -> new IllegalArgumentException("Invalid token"));

        if (token.isUsed()) {
            throw new IllegalStateException("Token already used");
        }

        if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalStateException("Token expired");
        }

        User user = token.getUser();
        user.setVerified(true);
        userRepository.save(user);

        token.setUsed(true);
        tokenRepository.save(token);
    }

    private String generateVerificationCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000); // 6 digits
        return String.valueOf(code);
    }
}
