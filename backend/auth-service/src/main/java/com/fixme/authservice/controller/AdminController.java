package com.fixme.authservice.controller;

import com.fixme.authservice.dto.PendingProviderDto;
import com.fixme.authservice.dto.UserSummaryDto;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.service.AdminService;
import com.fixme.authservice.service.ProviderAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminController {

    private final ProviderAdminService providerAdminService;
    private final UserRepository userRepository;
    private final AdminService adminService;   // 👈 جديد

    // ========= Providers =========

    @GetMapping("/providers/pending")
    public List<PendingProviderDto> getPendingProviders() {
        return providerAdminService.getPendingProviders();
    }

    @PostMapping("/providers/{userId}/approve")
    public void approveProvider(@PathVariable Long userId) {
        providerAdminService.approveProvider(userId);
    }

    @PostMapping("/providers/{userId}/reject")
    public void rejectProvider(@PathVariable Long userId) {
        providerAdminService.rejectProvider(userId);
    }

    @GetMapping("/providers")
    public List<UserSummaryDto> getAllProviders() {
        return userRepository.findByRole(UserRole.PROVIDER)
                .stream()
                .map(UserSummaryDto::fromEntity)
                .toList();
    }

    @GetMapping("/providers/{userId}")
    public ResponseEntity<UserSummaryDto> getProvider(@PathVariable Long userId) {
        return userRepository.findById(userId)
                .filter(u -> u.getRole() == UserRole.PROVIDER)
                .map(UserSummaryDto::fromEntity)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // حذف provider – نستعمل AdminService
    @DeleteMapping("/providers/{userId}")
    public void deleteProvider(@PathVariable Long userId) {
        adminService.deleteProvider(userId);
    }

    // ========= Customers =========

    @GetMapping("/customers")
    public List<UserSummaryDto> getAllCustomers() {
        return userRepository.findByRole(UserRole.CUSTOMER)
                .stream()
                .map(UserSummaryDto::fromEntity)
                .toList();
    }

    @GetMapping("/customers/{userId}")
    public ResponseEntity<UserSummaryDto> getCustomer(@PathVariable Long userId) {
        return userRepository.findById(userId)
                .filter(u -> u.getRole() == UserRole.CUSTOMER)
                .map(UserSummaryDto::fromEntity)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // حذف customer – نستعمل AdminService
    @DeleteMapping("/customers/{userId}")
    public void deleteCustomer(@PathVariable Long userId) {
        adminService.deleteCustomer(userId);
    }
}
