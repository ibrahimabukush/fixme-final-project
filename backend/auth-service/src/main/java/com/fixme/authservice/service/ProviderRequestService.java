package com.fixme.authservice.service;

import com.fixme.authservice.dto.NearbyRequestResponse;
import com.fixme.authservice.dto.ServiceRequestResponse;
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
        if (pLat == null || pLng == null) throw new IllegalStateException("Provider location not set");

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

    public List<ServiceRequestResponse> inbox(Long providerId, RequestStatus status) {
        User p = userRepository.findById(providerId)
                .orElseThrow(() -> new IllegalArgumentException("Provider not found"));
        if (p.getRole() != UserRole.PROVIDER) throw new IllegalStateException("Not provider");

        List<ServiceRequest> requests = (status == null)
                ? requestRepository.findByProviderIdOrderByCreatedAtDesc(providerId)
                : requestRepository.findByProviderIdAndStatusOrderByCreatedAtDesc(providerId, status);

        return requests.stream().map(this::toResponse).toList();
    }

    @Transactional
    public ServiceRequestResponse accept(Long providerId, Long requestId) {
        ServiceRequest r = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));

        if (r.getProvider() == null || !r.getProvider().getId().equals(providerId)) {
            throw new IllegalStateException("This request is not assigned to this provider");
        }
        if (r.getStatus() != RequestStatus.WAITING_PROVIDER) {
            throw new IllegalStateException("Request is not waiting for provider");
        }

        r.setStatus(RequestStatus.WAITING_CUSTOMER);
        return toResponse(requestRepository.save(r));
    }

    // ✅ NEW: provider sees only confirmed jobs (ACCEPTED)
    public List<ServiceRequestResponse> confirmedJobs(Long providerId) {
        User p = userRepository.findById(providerId)
                .orElseThrow(() -> new IllegalArgumentException("Provider not found"));
        if (p.getRole() != UserRole.PROVIDER) throw new IllegalStateException("Not provider");

        return requestRepository.findByProviderIdAndStatusOrderByCreatedAtDesc(providerId, RequestStatus.ACCEPTED)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    // ✅ NEW: provider updates progress stage
    @Transactional
    public ServiceRequestResponse updateProgress(Long providerId, Long requestId, ProgressStage stage) {
        ServiceRequest r = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));

        if (r.getProvider() == null || !r.getProvider().getId().equals(providerId)) {
            throw new IllegalStateException("Not your request");
        }

        // فقط بعد ما الزبون أكد
        if (r.getStatus() != RequestStatus.ACCEPTED && r.getStatus() != RequestStatus.DONE) {
            throw new IllegalStateException("Request not confirmed yet");
        }

        r.setProgressStage(stage);

        // optional: لو وصل DONE خلّي status DONE
        if (stage == ProgressStage.DONE) {
            r.setStatus(RequestStatus.DONE);
        }

        return toResponse(requestRepository.save(r));
    }

    private ServiceRequestResponse toResponse(ServiceRequest r) {
        Vehicle v = r.getVehicle();
        Long providerId = (r.getProvider() != null) ? r.getProvider().getId() : null;

        return new ServiceRequestResponse(
                r.getId(),
                r.getCustomer().getId(),
                providerId,
                v.getId(),
                v.getPlateNumber(),
                v.getMake(),
                v.getModel(),
                v.getYear(),
                r.getDescription(),
                v.getVehicleCategory(),
                r.getServiceType(),
                r.getLatitude(),
                r.getLongitude(),
                r.getStatus(),
                r.getProgressStage(),
                r.getCreatedAt()
        );
    }
}
