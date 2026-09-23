package com.unitconnect.thermal.controller;

import com.unitconnect.thermal.dto.HealthResponse;
import com.unitconnect.thermal.service.SystemHealthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;

/**
 * 서버와 DB 가 살아 있는지 확인하는 API (TEST 01, TEST 02).
 */
@Slf4j
@RestController
@RequestMapping("/api")
public class HealthController {

    private final String applicationName;
    private final SystemHealthService systemHealthService;

    public HealthController(@Value("${spring.application.name}") String applicationName,
                            SystemHealthService systemHealthService) {
        this.applicationName = applicationName;
        this.systemHealthService = systemHealthService;
    }

    @GetMapping("/health")
    public ResponseEntity<HealthResponse> health() {
        boolean databaseUp = systemHealthService.isDatabaseUp();
        log.debug("[SERVER] health check requested database={}", databaseUp ? "UP" : "DOWN");
        HealthResponse body = new HealthResponse(
                databaseUp ? "UP" : "DOWN",
                applicationName,
                databaseUp ? "UP" : "DOWN",
                OffsetDateTime.now());
        // DB 가 안 되면 503(서비스 사용 불가)으로 응답해 모니터링 도구가 이상을 알 수 있게 합니다
        return ResponseEntity.status(databaseUp ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE).body(body);
    }
}
