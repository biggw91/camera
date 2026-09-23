package com.unitconnect.thermal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

/**
 * mobile_device 테이블. Push 알림을 받을 스마트폰 1대 (FCM 기기 토큰).
 */
@Entity
@Table(name = "mobile_device")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MobileDevice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "device_token", nullable = false, unique = true, length = 512)
    private String deviceToken;

    @Column(name = "device_name", length = 100)
    private String deviceName;

    @Enumerated(EnumType.STRING)
    @Column(name = "platform", nullable = false, length = 20)
    private DevicePlatform platform;

    @Column(name = "enabled", nullable = false)
    private boolean enabled;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Builder
    private MobileDevice(String deviceToken, String deviceName, DevicePlatform platform) {
        this.deviceToken = deviceToken;
        this.deviceName = deviceName;
        this.platform = platform;
        this.enabled = true;
    }

    public void disable() {
        this.enabled = false;
    }
}
