package com.unitconnect.thermal.controller;

import com.unitconnect.thermal.dto.HealthResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;

/**
 * 서버가 살아 있는지 확인하는 API (TEST 01 서버 정상 실행).
 */
@Slf4j
@RestController
@RequestMapping("/api")
public class HealthController {

    private final String applicationName;

    public HealthController(@Value("${spring.application.name}") String applicationName) {
        this.applicationName = applicationName;
    }

    @GetMapping("/health")
    public HealthResponse health() {
        log.debug("[SERVER] health check requested");
        return new HealthResponse("UP", applicationName, OffsetDateTime.now());
    }
}
