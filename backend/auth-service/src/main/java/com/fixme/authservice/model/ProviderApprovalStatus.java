package com.fixme.authservice.model;

public enum ProviderApprovalStatus {
    NOT_PROVIDER,   // للـ customer
    PENDING,        // provider جديد ينتظر موافقة admin
    APPROVED,
    REJECTED
}
