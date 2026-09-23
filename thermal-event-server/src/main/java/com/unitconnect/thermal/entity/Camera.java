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
 * camera 테이블. 등록된 열화상 카메라 1대.
 */
@Entity
@Table(name = "camera")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Camera {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "camera_code", nullable = false, unique = true, length = 50)
    private String cameraCode;

    @Column(name = "camera_name", nullable = false, length = 100)
    private String cameraName;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "port")
    private Integer port;

    @Column(name = "location_name", length = 100)
    private String locationName;

    @Column(name = "installation_location", length = 255)
    private String installationLocation;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private CameraStatus status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Builder
    private Camera(String cameraCode, String cameraName, String ipAddress, Integer port,
                   String locationName, String installationLocation, CameraStatus status) {
        this.cameraCode = cameraCode;
        this.cameraName = cameraName;
        this.ipAddress = ipAddress;
        this.port = port;
        this.locationName = locationName;
        this.installationLocation = installationLocation;
        this.status = status != null ? status : CameraStatus.UNKNOWN;
    }

    public void changeStatus(CameraStatus status) {
        this.status = status;
    }
}
