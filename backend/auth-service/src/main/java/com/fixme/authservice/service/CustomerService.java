package com.fixme.authservice.service;

import com.fixme.authservice.dto.VehicleRequest;
import com.fixme.authservice.model.*;
import com.fixme.authservice.repository.ServiceRequestRepository;
import com.fixme.authservice.repository.UserRepository;
import com.fixme.authservice.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerService {
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final ServiceRequestRepository serviceRequestRepository;




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
        VehicleCategory category = request.getVehicleCategory() != null
                ? request.getVehicleCategory()
                : VehicleCategory.ALL;
        v.setVehicleCategory(category);

        return vehicleRepository.save(v);


    }
    public Vehicle updateVehicle(Long userId, Long vehicleId, VehicleRequest request) {


        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }


        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found"));


        if (!vehicle.getOwner().getId().equals(userId)) {
            throw new IllegalStateException("This vehicle does not belong to this user");
        }


        vehicle.setPlateNumber(request.getPlateNumber());
        vehicle.setMake(request.getMake());
        vehicle.setModel(request.getModel());
        vehicle.setYear(request.getYear());

        VehicleCategory category = request.getVehicleCategory() != null
                ? request.getVehicleCategory()
                : VehicleCategory.ALL;

        vehicle.setVehicleCategory(category);


        return vehicleRepository.save(vehicle);
    }
    public void deleteVehicle(Long userId, Long vehicleId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getRole() != UserRole.CUSTOMER) {
            throw new IllegalStateException("User is not a customer");
        }

        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(userId)) {
            throw new IllegalStateException("This vehicle does not belong to this user");
        }


        List<RequestStatus> active = List.of(
                RequestStatus.PENDING,
                RequestStatus.WAITING_PROVIDER,
                RequestStatus.WAITING_CUSTOMER,
                RequestStatus.ACCEPTED

        );

        boolean hasActiveRequests =
                serviceRequestRepository.existsByVehicleIdAndStatusIn(vehicleId, active);

        if (hasActiveRequests) {
            throw new IllegalStateException("VEHICLE_HAS_ACTIVE_REQUESTS");
        }

        // ✅ allowed: soft delete
        vehicle.setDeleted(true);
        vehicleRepository.save(vehicle);
    }




    public List<Vehicle> getVehicles(Long userId) {
        return vehicleRepository.findByOwnerIdAndDeletedFalse(userId);
    }
}
