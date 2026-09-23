package com.unitconnect.thermal.config;

import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
import org.springframework.boot.diagnostics.FailureAnalysis;

import java.sql.SQLException;

/**
 * DB 연결 실패로 서버가 켜지지 않을 때, 긴 오류 대신 원인과 해결 방법을 한국어로 보여줍니다.
 * (META-INF/spring.factories 에 등록되어 있습니다)
 */
public class DatabaseConnectionFailureAnalyzer extends AbstractFailureAnalyzer<SQLException> {

    private static final int MYSQL_DB_ACCESS_DENIED = 1044;
    private static final int MYSQL_ACCESS_DENIED = 1045;
    private static final int MYSQL_UNKNOWN_DATABASE = 1049;

    @Override
    protected FailureAnalysis analyze(Throwable rootFailure, SQLException cause) {
        String detail = cause.getMessage();
        if (cause.getErrorCode() == MYSQL_ACCESS_DENIED) {
            return new FailureAnalysis(
                    "[DB] MySQL 로그인 실패 (아이디 또는 비밀번호가 틀림): " + detail,
                    "저장소 최상위 .env 파일의 DB_USERNAME / DB_PASSWORD 를 확인하세요. "
                            + "모르면 tools\\windows\\setup-db.bat 을 다시 실행하면 새로 설정됩니다.",
                    cause);
        }
        if (cause.getErrorCode() == MYSQL_UNKNOWN_DATABASE || cause.getErrorCode() == MYSQL_DB_ACCESS_DENIED) {
            return new FailureAnalysis(
                    "[DB] DB 가 없거나, 이 계정에 해당 DB 사용 권한이 없습니다: " + detail,
                    "tools\\windows\\setup-db.bat 을 실행해 DB 를 만드세요. (.env 의 DB_NAME 도 확인)",
                    cause);
        }
        if (detail != null && detail.contains("Communications link failure")) {
            return new FailureAnalysis(
                    "[DB] MySQL 서버에 연결할 수 없습니다 (MySQL 이 꺼져 있거나 주소/포트가 다름).",
                    "1) Windows 서비스(services.msc)에서 MySQL80 이 '실행 중'인지 확인하세요. "
                            + "2) .env 의 DB_HOST / DB_PORT (기본 localhost / 3306) 를 확인하세요.",
                    cause);
        }
        return new FailureAnalysis(
                "[DB] DB 연결 또는 테이블 생성 중 오류: " + detail,
                "위 오류 내용을 복사해서 개발 담당(Claude)에게 전달해 주세요.",
                cause);
    }
}
