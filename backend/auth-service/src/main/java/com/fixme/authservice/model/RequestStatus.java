package com.fixme.authservice.model;

public enum RequestStatus {
    PENDING,
    WAITING_PROVIDER,
    WAITING_CUSTOMER,
    ACCEPTED,
    DONE,
    CANCELED
}