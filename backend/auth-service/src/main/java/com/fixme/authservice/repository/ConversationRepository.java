package com.fixme.authservice.repository;

import com.fixme.authservice.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByServiceRequestId(Long serviceRequestId);

    List<Conversation> findByCustomerId(Long customerId);
    List<Conversation> findByProviderId(Long providerId);

    void deleteByCustomerId(Long customerId);
    void deleteByProviderId(Long providerId);

    void deleteByServiceRequestIdIn(List<Long> serviceRequestIds);
}
