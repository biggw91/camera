-- =====================================================================
-- V1: 기본 테이블 생성 (camera, thermal_event, mobile_device)
--
-- - 이 파일은 서버가 처음 켜질 때 Flyway 가 자동으로 한 번만 실행합니다.
-- - 이미 적용된 파일은 절대 수정하지 않습니다. 변경이 필요하면 V2, V3 ... 새 파일을 추가합니다.
-- - 시간 값은 모두 UTC(세계 표준시, 한국시간 -9시간)로 저장합니다.
-- - 상태/종류 값(status, event_type 등)은 나중에 값을 추가하기 쉽도록 VARCHAR 로 저장합니다.
-- =====================================================================

CREATE TABLE camera (
    id                    BIGINT       NOT NULL AUTO_INCREMENT,
    camera_code           VARCHAR(50)  NOT NULL,              -- 예: CAM-001
    camera_name           VARCHAR(100) NOT NULL,
    ip_address            VARCHAR(45)  NULL,                  -- IPv4/IPv6. 하드코딩하지 않고 DB/설정으로 관리
    port                  INT          NULL,
    location_name         VARCHAR(100) NULL,                  -- 예: OO아파트
    installation_location VARCHAR(255) NULL,                  -- 예: B2 주차장 기둥 A-3
    status                VARCHAR(20)  NOT NULL,              -- UNKNOWN / ONLINE / OFFLINE
    created_at            DATETIME(6)  NOT NULL,
    updated_at            DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_camera_code UNIQUE (camera_code)
);

CREATE TABLE thermal_event (
    id          BIGINT        NOT NULL AUTO_INCREMENT,
    camera_id   BIGINT        NOT NULL,
    event_type  VARCHAR(20)   NOT NULL,                       -- TEMPERATURE / SMOKE / FLAME / FIRE_POINT / UNKNOWN
    event_level VARCHAR(20)   NOT NULL,                       -- INFO / WARNING / CRITICAL
    temperature DECIMAL(6, 2) NULL,                           -- ℃. 온도가 없는 이벤트(연기 등)는 NULL
    detected_at DATETIME(6)   NOT NULL,                       -- 카메라가 감지한 시각
    received_at DATETIME(6)   NOT NULL,                       -- 서버가 받은 시각
    status      VARCHAR(20)   NOT NULL,                       -- NEW / CONFIRMED / RESOLVED
    message     VARCHAR(500)  NULL,
    created_at  DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_thermal_event_camera FOREIGN KEY (camera_id) REFERENCES camera (id)
);

-- 중복 이벤트 확인(같은 카메라 + 같은 종류 + 최근 N초)용
CREATE INDEX idx_thermal_event_dedup ON thermal_event (camera_id, event_type, detected_at);
-- 최근 이벤트 / 미확인 이벤트 조회용
CREATE INDEX idx_thermal_event_detected_at ON thermal_event (detected_at);
CREATE INDEX idx_thermal_event_status ON thermal_event (status);

CREATE TABLE mobile_device (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    device_token VARCHAR(512) NOT NULL,                       -- FCM 기기 토큰
    device_name  VARCHAR(100) NULL,
    platform     VARCHAR(20)  NOT NULL,                       -- ANDROID / IOS
    enabled      BOOLEAN      NOT NULL,
    created_at   DATETIME(6)  NOT NULL,
    updated_at   DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_mobile_device_token UNIQUE (device_token)
);
