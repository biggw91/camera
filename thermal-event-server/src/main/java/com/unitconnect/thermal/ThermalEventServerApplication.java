package com.unitconnect.thermal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 서버 시작점. 이 클래스의 main 을 실행하면 서버가 켜집니다.
 */
@SpringBootApplication
public class ThermalEventServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ThermalEventServerApplication.class, args);
    }
}
