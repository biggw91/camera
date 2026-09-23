package com.unitconnect.thermal.repository;

import com.unitconnect.thermal.entity.ThermalEvent;
import org.springframework.data.jpa.repository.JpaRepository;

// TODO(Phase 4): 중복 이벤트 확인, 최근 이벤트 조회 메서드 추가
public interface ThermalEventRepository extends JpaRepository<ThermalEvent, Long> {
}
