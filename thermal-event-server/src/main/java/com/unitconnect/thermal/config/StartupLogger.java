package com.unitconnect.thermal.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * 서버가 완전히 켜졌을 때 접속 주소를 로그로 알려줍니다.
 */
@Slf4j
@Component
public class StartupLogger {

    private final Environment environment;

    public StartupLogger(Environment environment) {
        this.environment = environment;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        String port = environment.getProperty("local.server.port", environment.getProperty("server.port", "8080"));
        log.info("[SERVER] thermal-event-server started. health check: http://localhost:{}/api/health", port);
    }
}
