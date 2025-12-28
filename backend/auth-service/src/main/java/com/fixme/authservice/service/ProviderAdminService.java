package com.fixme.authservice.service;

import com.fixme.authservice.dto.PendingProviderDto;
import com.fixme.authservice.model.ProviderApprovalStatus;
import com.fixme.authservice.model.ProviderBusiness;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.ProviderBusinessRepository;
import com.fixme.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProviderAdminService {

    private final UserRepository userRepository;
    private final ProviderBusinessRepository providerBusinessRepository;

    public List<PendingProviderDto> getPendingProviders() {
        List<User> users = userRepository.findByRoleAndProviderApprovalStatus(
                UserRole.PROVIDER,
                ProviderApprovalStatus.PENDING
        );

        return users.stream()
                .map(user -> {
                    ProviderBusiness business = providerBusinessRepository
                            .findByUser(user)
                            .orElse(null);

                    return PendingProviderDto.builder()
                            .userId(user.getId())
                            .firstName(user.getFirstName())
                            .lastName(user.getLastName())
                            .email(user.getEmail())
                            .phone(user.getPhone())
                            .businessName(business != null ? business.getBusinessName() : null)
                            .city(business != null ? business.getCity() : null)
                            .address(business != null ? business.getAddress() : null)
                            .description(business != null ? business.getDescription() : null)
                            .services(business != null ? business.getServices() : null)
                            .openingHours(business != null ? business.getOpeningHours() : null)
                            .build();
                })
                .toList();
    }

    public void approveProvider(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        user.setProviderApprovalStatus(ProviderApprovalStatus.APPROVED);
        userRepository.save(user);
    }

    public void rejectProvider(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        user.setProviderApprovalStatus(ProviderApprovalStatus.REJECTED);
        userRepository.save(user);
    }
}
