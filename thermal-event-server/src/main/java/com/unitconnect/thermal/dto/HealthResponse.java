package com.unitconnect.thermal.dto;

import java.time.OffsetDateTime;

/**
 * GET /api/health 응답.
 *
 * @param status      서버 전체 상태 (DB 까지 정상이면 "UP", 아니면 "DOWN")
 * @param application 서버 이름
 * @param database    DB 연결 상태 ("UP" / "DOWN")
 * @param serverTime  서버 현재 시각
 */
public record HealthResponse(String status, String application, String database, OffsetDateTime serverTime) {
}
