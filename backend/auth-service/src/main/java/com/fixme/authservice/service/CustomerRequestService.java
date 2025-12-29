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

        ServiceRequest r = new ServiceRequest();
        r.setCustomer(user);
        r.setVehicle(vehicle);
        r.setDescription(req.getDescription());
        r.setLatitude(req.getLatitude());
        r.setLongitude(req.getLongitude());
        r.setVehicleCategory(vehicle.getVehicleCategory());

        ServiceRequest saved = requestRepository.save(r);

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ServiceRequestResponse> getMyRequests(Long userId) {
        return requestRepository.findByCustomerIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private ServiceRequestResponse toResponse(ServiceRequest r) {
        Vehicle v = r.getVehicle();

        return new ServiceRequestResponse(
                r.getId(),
                v.getId(),
                v.getPlateNumber(),
                v.getMake(),
                v.getModel(),
                v.getYear(),
                r.getVehicleCategory(),
                r.getLatitude(),
                r.getLongitude(),
                r.getStatus(),
                r.getCreatedAt()
        );
    }
}
