package com.fixme.authservice.repository;

import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.model.ProviderApprovalStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByPhone(String phone);
    List<User> findByRole(UserRole role);
    // 🔥 هاي اللي ناقصتك: كل البروڤايدر اللي حالتهم PENDING
    List<User> findByRoleAndProviderApprovalStatus(
            UserRole role,
            ProviderApprovalStatus providerApprovalStatus
    );
}
