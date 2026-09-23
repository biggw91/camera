package com.unitconnect.thermal.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * 서버/DB 상태 확인 (TEST 01 서버 정상 실행, TEST 02 DB 연결).
 */
@Slf4j
@Service
public class SystemHealthService {

    private final JdbcTemplate jdbcTemplate;

    public SystemHealthService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /** DB 에 간단한 질의(SELECT 1)를 보내 응답이 오면 true. */
    public boolean isDatabaseUp() {
        try {
            Integer result = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return Integer.valueOf(1).equals(result);
        } catch (Exception e) {
            log.error("[DB] health check failed: {}", e.getMessage());
            return false;
        }
    }
}
