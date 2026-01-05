package com.fixme.authservice.service;

import com.fixme.authservice.dto.*;
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
                .purpose(VerificationPurpose.SIGNUP)
                .used(false)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusMinutes(15))
                .build();

        tokenRepository.save(token);

        if (token.getType() == VerificationType.EMAIL) {
            emailService.sendVerificationCode(user.getEmail(), tokenCode);
        } else if (token.getType() == VerificationType.PHONE) {
            smsService.ifPresentOrElse(
                    s -> s.sendVerificationCode(user.getPhone(), tokenCode),
                    () -> System.out.println("SMS disabled (Twilio not configured). Code=" + tokenCode)
            );
        }

        System.out.println("SIGNUP VERIFICATION CODE for user " + user.getEmail() + " = " + tokenCode);
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

        if (user.getRole() == UserRole.PROVIDER &&
                user.getProviderApprovalStatus() != ProviderApprovalStatus.APPROVED) {
            throw new IllegalStateException("Provider not approved yet");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getId(), user.getRole());

        return new LoginResponse(user.getId(), user.getRole().name(), token);
    }

    @Transactional
    public void verify(VerificationRequest request) {
        VerificationToken token = tokenRepository.findByTokenCodeAndPurpose(
                        request.getTokenCode(),
                        VerificationPurpose.SIGNUP
                )
                .orElseThrow(() -> new IllegalArgumentException("Invalid token"));

        if (token.isUsed()) throw new IllegalStateException("Token already used");
        if (token.getExpiresAt().isBefore(LocalDateTime.now())) throw new IllegalStateException("Token expired");

        User user = token.getUser();
        user.setVerified(true);
        userRepository.save(user);

        token.setUsed(true);
        tokenRepository.save(token);
    }

    // ✅ NEW: Request reset code
    @Transactional
    public void requestPasswordReset(ForgotPasswordRequest request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByPhone(request.getIdentifier()));

        // Security: always respond OK in controller (don’t reveal existence)
        if (userOpt.isEmpty()) {
            return;
        }

        User user = userOpt.get();

        if (!user.isVerified()) {
            // You can decide: allow or not. I recommend allowing only verified users.
            throw new IllegalStateException("User not verified");
        }
        tokenRepository.findTopByUserAndPurposeOrderByCreatedAtDesc(user, VerificationPurpose.RESET_PASSWORD)
                .ifPresent(last -> {
                    if (last.getCreatedAt().isAfter(LocalDateTime.now().minusSeconds(30))) {
                        throw new IllegalStateException("You can resend code every 30 seconds");
                    }

                });

        String tokenCode = generateVerificationCode();

        VerificationToken token = VerificationToken.builder()
                .user(user)
                .tokenCode(tokenCode)
                .type(request.getVerificationType())
                .purpose(VerificationPurpose.RESET_PASSWORD)
                .used(false)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusSeconds(60))
                .build();

        tokenRepository.save(token);

        if (token.getType() == VerificationType.EMAIL) {
            emailService.sendVerificationCode(user.getEmail(), tokenCode);
        } else if (token.getType() == VerificationType.PHONE) {
            smsService.ifPresentOrElse(
                    s -> s.sendVerificationCode(user.getPhone(), tokenCode),
                    () -> System.out.println("SMS disabled. Reset code=" + tokenCode)
            );
        }

        System.out.println("RESET PASSWORD CODE for " + request.getIdentifier() + " = " + tokenCode);
    }

    // ✅ NEW: Reset password using code
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Passwords do not match");
        }

        User user = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByPhone(request.getIdentifier()))
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        VerificationToken token = tokenRepository.findByTokenCodeAndPurpose(
                        request.getTokenCode(),
                        VerificationPurpose.RESET_PASSWORD
                )
                .orElseThrow(() -> new IllegalArgumentException("Invalid token"));

        if (token.isUsed()) throw new IllegalStateException("Token already used");
        if (token.getExpiresAt().isBefore(LocalDateTime.now())) throw new IllegalStateException("Token expired");

        // Ensure the token belongs to the same user
        if (!token.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Invalid token");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        token.setUsed(true);
        tokenRepository.save(token);
    }

    private String generateVerificationCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }
    @Transactional
    public void resendSignupCode(ResendVerificationRequest request) {

        User user = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByPhone(request.getIdentifier()))
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // إذا صار Verified خلاص ما في داعي تبعت كود
        if (user.isVerified()) {
            throw new IllegalStateException("User already verified");
        }

        // ✅ cooldown 30 minutes based on last SIGNUP token
        tokenRepository.findTopByUserAndPurposeOrderByCreatedAtDesc(user, VerificationPurpose.SIGNUP)
                .ifPresent(last -> {
                    if (last.getCreatedAt().isAfter(LocalDateTime.now().minusSeconds(30))) {
                        throw new IllegalStateException("You can resend code every 30 seconds");
                    }

                });

        // (اختياري) احذف توكنات SIGNUP القديمة (أو خليها)
        tokenRepository.deleteAllByUserAndPurpose(user, VerificationPurpose.SIGNUP);

        String tokenCode = generateVerificationCode();

        VerificationToken token = VerificationToken.builder()
                .user(user)
                .tokenCode(tokenCode)
                .type(request.getVerificationType())
                .purpose(VerificationPurpose.SIGNUP)
                .used(false)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusMinutes(15))
                .build();

        tokenRepository.save(token);

        if (token.getType() == VerificationType.EMAIL) {
            emailService.sendVerificationCode(user.getEmail(), tokenCode);
        } else if (token.getType() == VerificationType.PHONE) {
            smsService.ifPresentOrElse(
                    s -> s.sendVerificationCode(user.getPhone(), tokenCode),
                    () -> System.out.println("SMS disabled. SIGNUP resend code=" + tokenCode)
            );
        }
    }

}
