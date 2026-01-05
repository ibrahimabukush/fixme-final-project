package com.fixme.authservice.repository;

import com.fixme.authservice.model.ChatMessage;
import com.fixme.authservice.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findByConversationOrderBySentAtAsc(Conversation conversation);
    void deleteByConversationIdIn(List<Long> conversationIds);
}

