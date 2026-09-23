package com.unitconnect.thermal.repository;

import com.unitconnect.thermal.entity.Camera;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CameraRepository extends JpaRepository<Camera, Long> {

    Optional<Camera> findByCameraCode(String cameraCode);
}
