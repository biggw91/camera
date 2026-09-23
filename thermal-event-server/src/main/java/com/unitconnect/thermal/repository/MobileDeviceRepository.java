package com.unitconnect.thermal.repository;

import com.unitconnect.thermal.entity.MobileDevice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MobileDeviceRepository extends JpaRepository<MobileDevice, Long> {

    Optional<MobileDevice> findByDeviceToken(String deviceToken);

    List<MobileDevice> findByEnabledTrue();
}
