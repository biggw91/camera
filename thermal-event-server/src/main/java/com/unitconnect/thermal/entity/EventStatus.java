package com.unitconnect.thermal.entity;

/**
 * 이벤트 처리 상태.
 */
public enum EventStatus {
    /** 새 이벤트 (미확인) */
    NEW,
    /** 담당자가 확인함 */
    CONFIRMED,
    /** 조치 완료 */
    RESOLVED
}
