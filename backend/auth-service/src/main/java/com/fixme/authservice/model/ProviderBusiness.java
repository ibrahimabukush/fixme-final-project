package com.fixme.authservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

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
    private String city;              // المدينة

    @Column(nullable = false)
    private String address;           // العنوان التفصيلي

    private String description;       // وصف قصير

    private String services;          // مثلاً "Towing, Tires, Garage"

    private String openingHours;      // مثلاً "Sun-Thu 09:00-18:00"

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
