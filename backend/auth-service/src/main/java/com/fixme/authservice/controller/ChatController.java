package com.fixme.authservice.controller;

import com.fixme.authservice.dto.*;
import com.fixme.authservice.model.Conversation;
import com.fixme.authservice.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    // ✅ get or create conversation by requestId
    @GetMapping("/request/{requestId}")
    public ConversationDto getConversation(@PathVariable Long requestId) {
        Conversation c = chatService.getOrCreateConversation(requestId);
        return ConversationDto.fromEntity(c);
    }

    // ✅ load messages
    @GetMapping("/{conversationId}/messages")
    public List<ChatMessageDto> getMessages(@PathVariable Long conversationId) {
        return chatService.getMessages(conversationId);
    }

    // ✅ WebSocket: send message
    @MessageMapping("/chat.send")
    public void sendMessageWs(SendChatMessageRequest req) {
        ChatMessageDto saved = chatService.sendMessage(
                req.getConversationId(),
                req.getSenderId(),
                req.getSenderRole(),
                req.getMessage()
        );

        // broadcast to both sides
        messagingTemplate.convertAndSend(
                "/topic/requests/" + saved.getConversationId(),
                saved
        );
    }
}
