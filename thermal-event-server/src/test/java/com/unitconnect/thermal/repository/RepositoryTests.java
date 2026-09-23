package com.unitconnect.thermal.repository;

import com.unitconnect.thermal.entity.Camera;
import com.unitconnect.thermal.entity.DevicePlatform;
import com.unitconnect.thermal.entity.EventLevel;
import com.unitconnect.thermal.entity.EventStatus;
import com.unitconnect.thermal.entity.EventType;
import com.unitconnect.thermal.entity.MobileDevice;
import com.unitconnect.thermal.entity.ThermalEvent;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * DB 테이블(Flyway)과 JPA 엔티티가 맞게 동작하는지 확인합니다.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class RepositoryTests {

    @Autowired
    private CameraRepository cameraRepository;
    @Autowired
    private ThermalEventRepository thermalEventRepository;
    @Autowired
    private MobileDeviceRepository mobileDeviceRepository;

    @Test
    void testCameraIsRegisteredByMigration() {
        Camera camera = cameraRepository.findByCameraCode("CAM-001").orElseThrow();

        assertThat(camera.getCameraName()).isEqualTo("Honeywell HT34B-423I");
        assertThat(camera.getLocationName()).isEqualTo("사무실");
    }

    @Test
    void savesThermalEventAsNew() {
        Camera camera = cameraRepository.findByCameraCode("CAM-001").orElseThrow();
        Instant now = Instant.now();

        ThermalEvent saved = thermalEventRepository.saveAndFlush(ThermalEvent.builder()
                .camera(camera)
                .eventType(EventType.TEMPERATURE)
                .eventLevel(EventLevel.CRITICAL)
                .temperature(new BigDecimal("85.50"))
                .detectedAt(now)
                .receivedAt(now)
                .message("고온 감지 테스트")
                .build());

        ThermalEvent found = thermalEventRepository.findById(saved.getId()).orElseThrow();
        assertThat(found.getStatus()).isEqualTo(EventStatus.NEW);
        assertThat(found.getTemperature()).isEqualByComparingTo("85.5");
        assertThat(found.getCreatedAt()).isNotNull();
    }

    @Test
    void rejectsDuplicateDeviceToken() {
        mobileDeviceRepository.saveAndFlush(MobileDevice.builder()
                .deviceToken("token-1").deviceName("테스트폰").platform(DevicePlatform.ANDROID).build());

        assertThat(mobileDeviceRepository.findByEnabledTrue()).hasSize(1);
        assertThatThrownBy(() -> mobileDeviceRepository.saveAndFlush(MobileDevice.builder()
                .deviceToken("token-1").platform(DevicePlatform.ANDROID).build()))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
