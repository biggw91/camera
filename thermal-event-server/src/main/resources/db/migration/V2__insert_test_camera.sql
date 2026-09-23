-- =====================================================================
-- V2: 테스트용 카메라 1대 등록 (CAM-001)
--
-- - Phase 4 테스트 이벤트 API 에서 cameraCode "CAM-001" 로 사용합니다.
-- - IP 주소는 아직 모르므로 비워 둡니다 (Phase 7 에서 확인 후 입력).
-- =====================================================================

INSERT INTO camera (camera_code, camera_name, ip_address, port, location_name, installation_location,
                    status, created_at, updated_at)
VALUES ('CAM-001', 'Honeywell HT34B-423I', NULL, NULL, '사무실', '설치 위치 확인 필요',
        'UNKNOWN', CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
