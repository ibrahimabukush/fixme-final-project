package com.fixme.authservice.repository;

import com.fixme.authservice.model.VerificationPurpose;
import com.fixme.authservice.model.VerificationToken;
import com.fixme.authservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VerificationTokenRepository extends JpaRepository<VerificationToken, Long> {

    Optional<VerificationToken> findByTokenCode(String tokenCode);

    // ✅ new: differentiate between SIGNUP code and RESET_PASSWORD code
    Optional<VerificationToken> findByTokenCodeAndPurpose(String tokenCode, VerificationPurpose purpose);

    // ✅ new: get latest token for a user by purpose (optional but useful)
    Optional<VerificationToken> findTopByUserAndPurposeOrderByCreatedAtDesc(User user, VerificationPurpose purpose);

    // حذف كل التوكنات تبع user معيّن
    void deleteAllByUser(User user);

    // ✅ optional: delete only tokens of a specific purpose
    void deleteAllByUserAndPurpose(User user, VerificationPurpose purpose);
}
