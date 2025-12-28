package com.fixme.authservice.repository;

import com.fixme.authservice.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    // كل السيارات تبع user معيّن
    List<Vehicle> findByOwnerId(Long ownerId);

    // حذف كل السيارات تبع user معيّن
    void deleteAllByOwnerId(Long ownerId);
}
