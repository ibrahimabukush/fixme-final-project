package com.fixme.authservice;

import com.fixme.authservice.model.ProviderApprovalStatus;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

import static com.fixme.authservice.model.UserRole.ADMIN;

@SpringBootApplication
public class AuthServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApplication.class, args);
    }

    @Bean
    public CommandLineRunner seedAdmin(UserRepository userRepository,
                                       PasswordEncoder passwordEncoder) {
        return args -> {
            String adminEmail = "admin@fixme.com";
            String adminPhone = "0500000000";
            String rawPass    = "Admin1234!";

            // ✅ check by email
            if (userRepository.findByEmail(adminEmail).isPresent()) {
                System.out.println("Admin already exists: " + adminEmail);
                return;
            }

            User admin = new User();
            admin.setFirstName("System");
            admin.setLastName("Admin");
            admin.setEmail(adminEmail);
            admin.setPhone(adminPhone);

            admin.setRole(UserRole.ADMIN);
            admin.setPasswordHash(passwordEncoder.encode(rawPass));

            // ✅ required fields in your entity
            admin.setVerified(true);
            admin.setProviderApprovalStatus(ProviderApprovalStatus.APPROVED); // change if your enum name differs
            admin.setCreatedAt(java.time.LocalDateTime.now());

            userRepository.save(admin);

            System.out.println("==================================");
            System.out.println("Admin created ✅");
            System.out.println("Email: " + adminEmail);
            System.out.println("Password: " + rawPass);
            System.out.println("==================================");
        };
    }

}
