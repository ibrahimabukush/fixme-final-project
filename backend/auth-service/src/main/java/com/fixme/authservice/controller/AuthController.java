package com.fixme.authservice.controller;

import com.fixme.authservice.dto.*;
import com.fixme.authservice.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin // عشان Flutter يقدر يتصل
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequest request) {
        authService.signup(request);
        return ResponseEntity.ok("Signup successful. Please check verification code.");
    }


    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse resp = authService.login(request);
            return ResponseEntity.ok(resp);
        } catch (IllegalArgumentException e) {
            // User not found / wrong password
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            // مثلا Provider not approved yet
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN) // 403
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verify(@RequestBody VerificationRequest request) {
        try {
            authService.verify(request);
            return ResponseEntity.ok(Map.of("message", "Verified OK"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Unexpected error while verifying"));
        }
    }
    @PostMapping("/forgot-password/request")
    public ResponseEntity<?> forgotPasswordRequest(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.requestPasswordReset(request);
        // Return generic message (security: don't reveal if user exists)
        return ResponseEntity.ok(Map.of("message", "If the account exists, a reset code was sent."));
    }

    // ✅ NEW: forgot password - reset password
    @PostMapping("/forgot-password/reset")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(Map.of("message", "Password updated successfully"));
    }
    @PostMapping("/verify/resend")
    public ResponseEntity<?> resendVerifyCode(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendSignupCode(request);
        return ResponseEntity.ok(Map.of("message", "Verification code resent (if allowed)."));
    }

}
