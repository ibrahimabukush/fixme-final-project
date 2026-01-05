package com.fixme.authservice.repository;

import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.model.ServiceRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceRequestRepository extends JpaRepository<ServiceRequest, Long> {

    List<ServiceRequest> findByCustomerIdOrderByCreatedAtDesc(Long customerId);
    List<ServiceRequest> findByStatus(RequestStatus status);
    List<ServiceRequest> findByProviderIdOrderByCreatedAtDesc(Long providerId);
    List<ServiceRequest> findByProviderIdAndStatusOrderByCreatedAtDesc(Long providerId, RequestStatus status);

    boolean existsByVehicleIdAndStatusIn(Long vehicleId, List<RequestStatus> statuses);

    // ✅ needed for delete flow
    List<ServiceRequest> findByCustomerId(Long customerId);
    List<ServiceRequest> findByProviderId(Long providerId);

    void deleteByCustomerId(Long customerId);
    void deleteByProviderId(Long providerId);
}
