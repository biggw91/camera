package com.unitconnect.thermal.dto;

import java.time.OffsetDateTime;

/**
 * GET /api/health 응답.
 *
 * @param status      서버 상태 (정상이면 "UP")
 * @param application 서버 이름
 * @param serverTime  서버 현재 시각
 */
public record HealthResponse(String status, String application, OffsetDateTime serverTime) {
}
