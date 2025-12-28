package com.fixme.authservice.service;

import com.fixme.authservice.dto.VehicleRequest;
import com.fixme.authservice.model.User;
import com.fixme.authservice.model.UserRole;
import com.fixme.authservice.model.Vehicle;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerService {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;

    public Vehicle addVehicle(Long userId, VehicleRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }

        Vehicle v = new Vehicle();
        v.setOwner(user);
        v.setPlateNumber(request.getPlateNumber());
        v.setMake(request.getMake());
        v.setModel(request.getModel());
        v.setYear(request.getYear());

        return vehicleRepository.save(v);
    }

    public List<Vehicle> getVehicles(Long userId) {
        return vehicleRepository.findByOwnerId(userId);
    }
}
