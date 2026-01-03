package com.fixme.authservice.dto;

import com.fixme.authservice.model.UserRole;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SendChatMessageRequest {
    private Long conversationId;

    private Long senderId;
    private UserRole senderRole; // CUSTOMER / PROVIDER
    private String message;
}
