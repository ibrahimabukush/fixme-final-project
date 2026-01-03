package com.fixme.authservice.service;

import com.fixme.authservice.dto.ServiceRequestCreateRequest;
import com.fixme.authservice.dto.ServiceRequestResponse;
import com.fixme.authservice.model.*;
import com.fixme.authservice.repository.ServiceRequestRepository;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerRequestService {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final ServiceRequestRepository requestRepository;

    public ServiceRequestResponse createRequest(Long userId, ServiceRequestCreateRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }

        Vehicle vehicle = vehicleRepository.findById(req.getVehicleId())
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(userId)) {
            throw new IllegalStateException("Vehicle does not belong to this customer");
        }

        // ✅ NEW: serviceType required
        if (req.getServiceType() == null) {
            throw new IllegalArgumentException("serviceType is required");
        }

        ServiceRequest r = new ServiceRequest();
        r.setCustomer(user);
        r.setVehicle(vehicle);

        r.setDescription(req.getDescription());
        r.setLatitude(req.getLatitude());
        r.setLongitude(req.getLongitude());

        // يعتمد على السيارة
        r.setVehicleCategory(vehicle.getVehicleCategory());

        // ✅ NEW: store requested service type (oil change / towing / etc)
        r.setServiceType(req.getServiceType());

        r.setProvider(null);
        r.setStatus(RequestStatus.PENDING);

        // ✅ default progress
        r.setProgressStage(ProgressStage.ON_THE_WAY);

        return toResponse(requestRepository.save(r));
    }

    public ServiceRequestResponse assignProvider(Long customerId, Long requestId, Long providerId) {
        ServiceRequest r = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));

        if (!r.getCustomer().getId().equals(customerId)) {
            throw new IllegalStateException("Not your request");
        }

        if (r.getStatus() != RequestStatus.PENDING) {
            throw new IllegalStateException("Request is not in PENDING state");
        }

        User provider = userRepository.findById(providerId)
                .orElseThrow(() -> new IllegalArgumentException("Provider not found"));

        if (provider.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        r.setProvider(provider);
        r.setStatus(RequestStatus.WAITING_PROVIDER);

        return toResponse(requestRepository.save(r));
    }

    @Transactional(readOnly = true)
    public List<ServiceRequestResponse> getMyRequests(Long userId) {
        return requestRepository.findByCustomerIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public ServiceRequestResponse confirm(Long customerId, Long requestId) {
        ServiceRequest r = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));

        if (!r.getCustomer().getId().equals(customerId)) {
            throw new IllegalStateException("Not your request");
        }

        if (r.getStatus() != RequestStatus.WAITING_CUSTOMER) {
            throw new IllegalStateException("Request is not waiting for customer confirm");
        }

        r.setStatus(RequestStatus.ACCEPTED);
        return toResponse(requestRepository.save(r));
    }

    private ServiceRequestResponse toResponse(ServiceRequest r) {
        Vehicle v = r.getVehicle();
        Long providerId = (r.getProvider() != null) ? r.getProvider().getId() : null;

        // ✅ IMPORTANT:
        // This constructor must match your updated ServiceRequestResponse DTO
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
                r.getServiceType(),          // ✅ NEW
                r.getLatitude(),
                r.getLongitude(),
                r.getStatus(),
                r.getProgressStage(),
                r.getCreatedAt()
        );
    }
}
