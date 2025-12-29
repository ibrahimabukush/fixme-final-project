package com.fixme.authservice.dto;

import com.fixme.authservice.model.VehicleCategory;

public class VehicleResponse {

    private Long id;
    private String plateNumber;
    private String make;
    private String model;
    private Integer year;
    private VehicleCategory vehicleCategory;  // 👈 الجديد

    // 👇 Constructor بدون باراميترات (مهم للـ Jackson لو احتجته)
    public VehicleResponse() {
    }

    // 👈 الكونستركتور الجديد بـ 6 باراميترات
    public VehicleResponse(
            Long id,
            String plateNumber,
            String make,
            String model,
            Integer year,
            VehicleCategory vehicleCategory
    ) {
        this.id = id;
        this.plateNumber = plateNumber;
        this.make = make;
        this.model = model;
        this.year = year;
        this.vehicleCategory = vehicleCategory;
    }

    // (اختياري) لو عندك كود قديم لسه يستعمل الكونستركتور القديم 5 باراميترات:
    public VehicleResponse(
            Long id,
            String plateNumber,
            String make,
            String model,
            Integer year
    ) {
        this(id, plateNumber, make, model, year, null);
    }

    // ====== Getters & Setters ======

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public VehicleCategory getVehicleCategory() {
        return vehicleCategory;
    }

    public void setVehicleCategory(VehicleCategory vehicleCategory) {
        this.vehicleCategory = vehicleCategory;
    }
}
