package com.fixme.authservice.dto;

import com.fixme.authservice.model.Conversation;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConversationDto {

    private Long id;
    private Long serviceRequestId;
    private Long customerId;
    private Long providerId;
    private LocalDateTime createdAt;

    public static ConversationDto fromEntity(Conversation c) {
        return ConversationDto.builder()
                .id(c.getId())
                .serviceRequestId(c.getServiceRequest().getId())
                .customerId(c.getCustomer().getId())
                .providerId(c.getProvider().getId())
                .createdAt(c.getCreatedAt())
                .build();
    }
}
