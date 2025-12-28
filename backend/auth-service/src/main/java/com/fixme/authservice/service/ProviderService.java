package com.fixme.authservice.service;

import com.fixme.authservice.dto.ProviderBusinessRequest;
import com.fixme.authservice.dto.ProviderBusinessResponse;
import com.fixme.authservice.model.ProviderBusiness;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.ProviderBusinessRepository;
import com.fixme.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ProviderService {

    private final UserRepository userRepository;
    private final ProviderBusinessRepository businessRepository;

    @Transactional
    public ProviderBusinessResponse createOrUpdateBusiness(Long userId, ProviderBusinessRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        ProviderBusiness business = businessRepository.findByUserId(userId)
                .orElseGet(() -> {
                    ProviderBusiness b = new ProviderBusiness();
                    b.setUser(user);
                    b.setCreatedAt(LocalDateTime.now());
                    return b;
                });

        business.setBusinessName(request.getBusinessName());
        business.setCity(request.getCity());
        business.setAddress(request.getAddress());
        business.setDescription(request.getDescription());
        business.setServices(request.getServices());
        business.setOpeningHours(request.getOpeningHours());
        business.setUpdatedAt(LocalDateTime.now());

        ProviderBusiness saved = businessRepository.save(business);

        return ProviderBusinessResponse.builder()
                .id(saved.getId())
                .userId(user.getId())
                .businessName(saved.getBusinessName())
                .city(saved.getCity())
                .address(saved.getAddress())
                .description(saved.getDescription())
                .services(saved.getServices())
                .openingHours(saved.getOpeningHours())
                .build();
    }

    @Transactional(readOnly = true)
    public ProviderBusinessResponse getBusiness(Long userId) {
        ProviderBusiness business = businessRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Business not found for provider"));

        return ProviderBusinessResponse.builder()
                .id(business.getId())
                .userId(business.getUser().getId())
                .businessName(business.getBusinessName())
                .city(business.getCity())
                .address(business.getAddress())
                .description(business.getDescription())
                .services(business.getServices())
                .openingHours(business.getOpeningHours())
                .build();
    }
}
