package com.fixme.authservice.repository;
import com.fixme.authservice.model.RequestStatus;
import com.fixme.authservice.model.ServiceRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceRequestRepository extends JpaRepository<ServiceRequest, Long> {
    List<ServiceRequest> findByCustomerIdOrderByCreatedAtDesc(Long customerId);
    List<ServiceRequest> findByStatus(RequestStatus status);
}
