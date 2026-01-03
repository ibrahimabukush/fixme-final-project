package com.fixme.authservice.dto;

import com.fixme.authservice.model.ChatMessage;
import com.fixme.authservice.model.UserRole;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDto {

    private Long id;
    private Long conversationId;
    private Long senderId;
    private UserRole senderRole;
    private String message;
    private LocalDateTime sentAt;

    public static ChatMessageDto fromEntity(ChatMessage m) {
        return ChatMessageDto.builder()
                .id(m.getId())
                .conversationId(m.getConversation().getId())
                .senderId(m.getSender().getId())
                .senderRole(m.getSenderRole())
                .message(m.getMessage())
                .sentAt(m.getSentAt())
                .build();
    }
}
