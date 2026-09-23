package com.unitconnect.thermal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * thermal_event 테이블. 카메라(또는 테스트 API)에서 받은 이벤트 1건.
 */
@Entity
@Table(name = "thermal_event")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ThermalEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "camera_id", nullable = false)
    private Camera camera;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false, length = 20)
    private EventType eventType;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_level", nullable = false, length = 20)
    private EventLevel eventLevel;

    /** ℃. 온도가 없는 이벤트는 null. */
    @Column(name = "temperature", precision = 6, scale = 2)
    private BigDecimal temperature;

    @Column(name = "detected_at", nullable = false)
    private Instant detectedAt;

    @Column(name = "received_at", nullable = false)
    private Instant receivedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private EventStatus status;

    @Column(name = "message", length = 500)
    private String message;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Builder
    private ThermalEvent(Camera camera, EventType eventType, EventLevel eventLevel, BigDecimal temperature,
                         Instant detectedAt, Instant receivedAt, String message) {
        this.camera = camera;
        this.eventType = eventType;
        this.eventLevel = eventLevel;
        this.temperature = temperature;
        this.detectedAt = detectedAt;
        this.receivedAt = receivedAt;
        this.message = message;
        this.status = EventStatus.NEW;
    }

    public void changeStatus(EventStatus status) {
        this.status = status;
    }
}
