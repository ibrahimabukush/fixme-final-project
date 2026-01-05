package com.fixme.authservice.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "vehicles")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // صاحب السيارة
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User owner;

    @Column(nullable = false)
    private String plateNumber; // رقم السيارة

    @Column(nullable = false)
    private String make;        // الشركة المصنعة (Toyota, BMW...)

    @Column(nullable = false)
    private String model;       // موديل السيارة (Corolla, A4...)

    private Integer year;       // سنة الصنع (اختياري)

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    @Enumerated(EnumType.STRING)
    private VehicleCategory vehicleCategory = VehicleCategory.ALL;

    public Vehicle() {
    }
    @Column(nullable = false)
    private boolean deleted = false;


    // ====== Getters & Setters ======
    public Long getId() {
        return id;
    }

    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    public void setVehicleCategory(VehicleCategory vehicleCategory) {
        this.vehicleCategory = vehicleCategory;
    }
    public VehicleCategory getVehicleCategory() {
        return vehicleCategory;
    }
    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

}
