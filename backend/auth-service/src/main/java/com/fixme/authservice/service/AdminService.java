package com.fixme.authservice.service;

import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.ProviderBusinessRepository;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.repository.VehicleRepository;
import com.fixme.authservice.repository.VerificationTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final ProviderBusinessRepository providerBusinessRepository;
    private final VerificationTokenRepository verificationTokenRepository;

    // حذف Customer
    public void deleteCustomer(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }

        // 1) حذف السيارات
        vehicleRepository.deleteAllByOwnerId(userId);

        // 2) حذف التوكنات
        verificationTokenRepository.deleteAllByUser(user);

        // 3) حذف اليوزر نفسه
        userRepository.delete(user);
    }

    // حذف Provider
    public void deleteProvider(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        // 1) حذف الـ business record
        providerBusinessRepository.deleteByUser(user);

        // 2) لو مستقبلاً عنده سيارات كمان
        vehicleRepository.deleteAllByOwnerId(userId);

        // 3) حذف التوكنات
        verificationTokenRepository.deleteAllByUser(user);

        // 4) حذف اليوزر
        userRepository.delete(user);
    }
}
