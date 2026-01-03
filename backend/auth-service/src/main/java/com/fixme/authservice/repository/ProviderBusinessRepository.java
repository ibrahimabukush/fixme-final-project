package com.fixme.authservice.repository;

import com.fixme.authservice.model.ProviderBusiness;
import com.fixme.authservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProviderBusinessRepository extends JpaRepository<ProviderBusiness, Long> {

    Optional<ProviderBusiness> findByUserId(Long userId);
    Optional<ProviderBusiness> findByUser(User user);

    // حذف الـ business تبع provider معيّن
    void deleteByUser(User user);
    List<ProviderBusiness> findByLatitudeNotNullAndLongitudeNotNull();

}
