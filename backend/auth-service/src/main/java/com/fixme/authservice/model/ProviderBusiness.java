package com.fixme.authservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.Set;

@Entity
@Table(name = "provider_business")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProviderBusiness {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // كل Provider إله بزنس واحد
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false)
    private String businessName;      // اسم الكراج / البزنس

    @Column(nullable = false)
    private String city;              // المدينة (نتركها زي ما هي)

    @Column(nullable = false)
    private String address;           // العنوان التفصيلي (نتركها زي ما هي)

    private String description;       // وصف قصير
    private String services;          // مثلاً "Towing, Tires, Garage"
    private String openingHours;      // مثلاً "Sun-Thu 09:00-18:00"
    @ElementCollection(fetch = FetchType.EAGER)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "provider_business_categories", joinColumns = @JoinColumn(name = "business_id"))
    @Column(name = "category")
    private java.util.Set<VehicleCategory> categories;
    @ElementCollection(fetch = FetchType.EAGER)
    @Enumerated(EnumType.STRING)
    @CollectionTable(
            name = "provider_business_offered_services",
            joinColumns = @JoinColumn(name = "business_id")
    )
    @Column(name = "service_type")
    private Set<ServiceType> offeredServices;
    // ✅ NEW: provider location
    @Column(nullable = true)
    private Double latitude;

    @Column(nullable = true)
    private Double longitude;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
