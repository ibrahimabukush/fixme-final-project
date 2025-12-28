package com.fixme.authservice.repository;

import com.fixme.authservice.model.VerificationToken;
import com.fixme.authservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VerificationTokenRepository extends JpaRepository<VerificationToken, Long> {

    Optional<VerificationToken> findByTokenCode(String tokenCode);

    // حذف كل التوكنات تبع user معيّن
    void deleteAllByUser(User user);
}
