package com.fixme.authservice.service;

import com.fixme.authservice.dto.NearbyRequestResponse;
import com.fixme.authservice.model.*;
import com.fixme.authservice.repository.ProviderBusinessRepository;
import com.fixme.authservice.repository.ServiceRequestRepository;
import com.fixme.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProviderRequestService {

    private final UserRepository userRepository;
    private final ProviderBusinessRepository businessRepository;
    private final ServiceRequestRepository requestRepository;

    public List<NearbyRequestResponse> nearby(Long providerId, double radiusKm) {

        User provider = userRepository.findById(providerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (provider.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        ProviderBusiness business = businessRepository.findByUserId(providerId)
                .orElseThrow(() -> new IllegalStateException("Business not found for provider"));

        Double pLat = business.getLatitude();
        Double pLng = business.getLongitude();

        if (pLat == null || pLng == null) {
            throw new IllegalStateException("Provider location not set");
        }

        return requestRepository.findByStatus(RequestStatus.PENDING)
                .stream()
                .map(r -> {
                    double dist = haversineKm(pLat, pLng, r.getLatitude(), r.getLongitude());
                    Vehicle v = r.getVehicle();
                    return new NearbyRequestResponse(
                            r.getId(),
                            r.getCustomer().getId(),
                            v.getId(),
                            v.getPlateNumber(),
                            v.getMake(),
                            v.getModel(),
                            v.getYear(),
                            r.getDescription(),
                            r.getVehicleCategory(),
                            r.getLatitude(),
                            r.getLongitude(),
                            dist,
                            r.getStatus(),
                            r.getCreatedAt()
                    );
                })
                .filter(dto -> dto.getDistanceKm() <= radiusKm)
                .sorted(Comparator.comparingDouble(NearbyRequestResponse::getDistanceKm))
                .toList();
    }

    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
