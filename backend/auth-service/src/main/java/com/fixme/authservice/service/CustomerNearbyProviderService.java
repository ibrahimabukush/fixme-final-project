package com.fixme.authservice.service;

import com.fixme.authservice.dto.NearbyProviderResponse;
import com.fixme.authservice.model.ProviderBusiness;
import com.fixme.authservice.model.ServiceType;
import com.fixme.authservice.model.VehicleCategory;
import com.fixme.authservice.repository.ProviderBusinessRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerNearbyProviderService {

    private final ProviderBusinessRepository businessRepository;

    public List<NearbyProviderResponse> nearbyProviders(
            double lat,
            double lng,
            double radiusKm,
            VehicleCategory category,
            ServiceType serviceType
    ) {

        List<ProviderBusiness> all = businessRepository.findByLatitudeNotNullAndLongitudeNotNull();

        return all.stream()
                .filter(b -> b.getLatitude() != null && b.getLongitude() != null)

                // ✅ Filter by vehicle category
                .filter(b -> {
                    if (b.getCategories() == null || b.getCategories().isEmpty()) return false;
                    return b.getCategories().contains(VehicleCategory.ALL)
                            || b.getCategories().contains(category);
                })

                // ✅ NEW: Filter by service type
                .filter(b -> {
                    if (b.getOfferedServices() == null || b.getOfferedServices().isEmpty()) return false;
                    return b.getOfferedServices().contains(serviceType);
                })

                // distance calc
                .map(b -> {
                    double d = haversineKm(lat, lng, b.getLatitude(), b.getLongitude());
                    return new Object[]{b, d};
                })

                // within radius
                .filter(arr -> (double) arr[1] <= radiusKm)

                // sort by distance
                .sorted(Comparator.comparingDouble(arr -> (double) arr[1]))

                // map to DTO
                .map(arr -> {
                    ProviderBusiness b = (ProviderBusiness) arr[0];
                    double d = (double) arr[1];

                    return NearbyProviderResponse.builder()
                            .userId(b.getUser().getId())
                            .businessId(b.getId())
                            .businessName(b.getBusinessName())
                            .description(b.getDescription())

                            // نص عام (optional)
                            .services(b.getServices())

                            // ✅ NEW
                            .offeredServices(b.getOfferedServices())

                            .openingHours(b.getOpeningHours())
                            .latitude(b.getLatitude())
                            .longitude(b.getLongitude())
                            .categories(b.getCategories())
                            .distanceKm(d)
                            .build();
                })
                .collect(Collectors.toList());
    }

    // ✅ Haversine
    private static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                                Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
