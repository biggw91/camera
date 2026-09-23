package com.unitconnect.thermal.entity;

/**
 * 이벤트 종류. 카메라가 실제로 어떤 값을 보내는지는 Phase 8 에서 확인합니다.
 */
public enum EventType {
    /** 온도 감지 (고온) */
    TEMPERATURE,
    /** 연기 감지 */
    SMOKE,
    /** 불꽃 감지 */
    FLAME,
    /** 화점 감지 (Fire Point) */
    FIRE_POINT,
    /** 알 수 없는 이벤트 */
    UNKNOWN
}
