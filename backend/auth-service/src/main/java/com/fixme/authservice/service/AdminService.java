package com.fixme.authservice.service;

import com.fixme.authservice.model.Conversation;
import com.fixme.authservice.model.ServiceRequest;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.repository.*;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final ProviderBusinessRepository providerBusinessRepository;
    private final VerificationTokenRepository verificationTokenRepository;

    // ✅ NEW
    private final ServiceRequestRepository serviceRequestRepository;
    private final ConversationRepository conversationRepository;
    private final ChatMessageRepository chatMessageRepository;

    public void deleteCustomer(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }

        // ✅ 1) delete chat/conversations/serviceRequests first (they block vehicles/users)
        deleteCustomerRelations(userId);

        // ✅ 2) delete vehicles (now safe)
        vehicleRepository.deleteAllByOwnerId(userId);

        // ✅ 3) delete tokens
        verificationTokenRepository.deleteAllByUser(user);

        // ✅ 4) delete user
        userRepository.delete(user);
    }

    public void deleteProvider(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.PROVIDER) {
            throw new IllegalStateException("User is not a provider");
        }

        // ✅ 1) delete chat/conversations/serviceRequests first (they block provider/user)
        deleteProviderRelations(userId);

        // ✅ 2) delete provider business
        providerBusinessRepository.deleteByUser(user);

        // ✅ 3) if provider has vehicles too (optional)
        vehicleRepository.deleteAllByOwnerId(userId);

        // ✅ 4) delete tokens
        verificationTokenRepository.deleteAllByUser(user);

        // ✅ 5) delete user
        userRepository.delete(user);
    }

    // -------------------------
    // Helpers (the important part)
    // -------------------------

    private void deleteCustomerRelations(Long customerId) {

        // A) delete conversations where customerId is used directly (and their chat messages)
        List<Conversation> customerConvs = conversationRepository.findByCustomerId(customerId);
        deleteChatMessagesThenConversations(customerConvs);

        // B) delete service requests by customer (and anything linked to them)
        List<ServiceRequest> customerRequests = serviceRequestRepository.findByCustomerId(customerId);
        deleteRequestsCascade(customerRequests);

        // Finally delete remaining SR rows
        serviceRequestRepository.deleteByCustomerId(customerId);
    }

    private void deleteProviderRelations(Long providerId) {

        // A) delete conversations where providerId is used directly (and their chat messages)
        List<Conversation> providerConvs = conversationRepository.findByProviderId(providerId);
        deleteChatMessagesThenConversations(providerConvs);

        // B) delete service requests assigned to provider
        List<ServiceRequest> providerRequests = serviceRequestRepository.findByProviderId(providerId);
        deleteRequestsCascade(providerRequests);

        // Finally delete remaining SR rows
        serviceRequestRepository.deleteByProviderId(providerId);
    }

    private void deleteRequestsCascade(List<ServiceRequest> requests) {
        if (requests == null || requests.isEmpty()) return;

        List<Long> srIds = requests.stream()
                .map(ServiceRequest::getId)
                .toList();

        // 1) delete conversations that are linked by serviceRequestId (and their chat messages)
        //    We might not have a "findByServiceRequestIdIn", so we delete conversations by ids:
        //    First get conversations via customer/provider already handled above, but this is extra safe:
        conversationRepository.deleteByServiceRequestIdIn(srIds);

        // NOTE:
        // If your DB FK is: conversations.service_request_id -> service_requests.id
        // and you want to delete chat_messages too, you should fetch conv ids before deletion.
        // If you want it fully safe, add a method: List<Conversation> findByServiceRequestIdIn(List<Long> ids)
        // then delete chat_messages, then conversations.
    }

    private void deleteChatMessagesThenConversations(List<Conversation> convs) {
        if (convs == null || convs.isEmpty()) return;

        List<Long> convIds = convs.stream()
                .map(Conversation::getId)
                .toList();

        // ✅ must delete chat_messages first
        chatMessageRepository.deleteByConversationIdIn(convIds);

        // ✅ then conversations
        conversationRepository.deleteAllById(convIds);
    }
}
