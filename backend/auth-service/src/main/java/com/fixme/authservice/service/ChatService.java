package com.fixme.authservice.service;

import com.fixme.authservice.dto.ChatMessageDto;
import com.fixme.authservice.model.*;
import com.fixme.authservice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ServiceRequestRepository serviceRequestRepository;
    private final UserRepository userRepository;

    @Transactional
    public Conversation getOrCreateConversation(Long requestId) {
        return conversationRepository.findByServiceRequestId(requestId)
                .orElseGet(() -> {
                    ServiceRequest r = serviceRequestRepository.findById(requestId)
                            .orElseThrow(() -> new IllegalArgumentException("Request not found"));

                    Conversation c = Conversation.builder()
                            .serviceRequest(r)
                            .customer(r.getCustomer())
                            .provider(r.getProvider())
                            .createdAt(LocalDateTime.now())
                            .build();

                    return conversationRepository.save(c);
                });
    }

    @Transactional(readOnly = true)
    public List<ChatMessageDto> getMessages(Long conversationId) {
        Conversation c = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        return chatMessageRepository
                .findByConversationOrderBySentAtAsc(c)
                .stream()
                .map(ChatMessageDto::fromEntity)
                .toList();
    }

    @Transactional
    public ChatMessageDto sendMessage(
            Long conversationId,
            Long senderId,
            UserRole senderRole,
            String message
    ) {
        Conversation c = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));

        ChatMessage m = ChatMessage.builder()
                .conversation(c)
                .sender(sender)
                .senderRole(senderRole)
                .message(message)
                .sentAt(LocalDateTime.now())
                .build();

        return ChatMessageDto.fromEntity(chatMessageRepository.save(m));
    }
}
