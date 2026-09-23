package com.unitconnect.thermal.config;

import com.unitconnect.thermal.repository.CameraRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

/**
 * 서버가 완전히 켜졌을 때 DB 연결 정보와 접속 주소를 로그로 알려줍니다.
 * (비밀번호는 로그에 남기지 않습니다)
 */
@Slf4j
@Component
public class StartupLogger {

    private final Environment environment;
    private final DataSource dataSource;
    private final CameraRepository cameraRepository;

    public StartupLogger(Environment environment, DataSource dataSource, CameraRepository cameraRepository) {
        this.environment = environment;
        this.dataSource = dataSource;
        this.cameraRepository = cameraRepository;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData meta = connection.getMetaData();
            log.info("[DB] connected: {} {} url={} user={}",
                    meta.getDatabaseProductName(), meta.getDatabaseProductVersion(),
                    stripQuery(meta.getURL()), meta.getUserName());
            log.info("[DB] registered cameras={}", cameraRepository.count());
        } catch (Exception e) {
            log.error("[DB] connection check failed: {}", e.getMessage());
        }

        String port = environment.getProperty("local.server.port", environment.getProperty("server.port", "8080"));
        log.info("[SERVER] thermal-event-server started. health check: http://localhost:{}/api/health", port);
    }

    /** 접속 주소 뒤의 옵션(?...)은 길기만 해서 로그에서 뺍니다. */
    private static String stripQuery(String url) {
        int index = url.indexOf('?');
        return index < 0 ? url : url.substring(0, index);
    }
}
