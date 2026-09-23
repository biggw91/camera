package com.unitconnect.thermal.entity;

/**
 * 카메라 연결 상태.
 */
public enum CameraStatus {
    /** 아직 확인 안 됨 (Phase 7 에서 연결 확인 기능 추가 예정) */
    UNKNOWN,
    /** 연결됨 */
    ONLINE,
    /** 연결 안 됨 */
    OFFLINE
}
