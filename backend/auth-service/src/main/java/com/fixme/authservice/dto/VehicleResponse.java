package com.fixme.authservice.dto;

public class VehicleResponse {

    private Long id;
    private String plateNumber;
    private String make;
    private String model;
    private Integer year;

    public VehicleResponse(Long id, String plateNumber, String make, String model, Integer year) {
        this.id = id;
        this.plateNumber = plateNumber;
        this.make = make;
        this.model = model;
        this.year = year;
    }

    public Long getId() {
        return id;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public String getMake() {
        return make;
    }

    public String getModel() {
        return model;
    }

    public Integer getYear() {
        return year;
    }
}
