package com.fixme.authservice.repository;

import com.fixme.authservice.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByServiceRequestId(Long serviceRequestId);
}
