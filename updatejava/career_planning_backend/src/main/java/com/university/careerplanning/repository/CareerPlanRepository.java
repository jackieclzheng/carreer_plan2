
package com.university.careerplanning.repository;

import com.university.careerplanning.model.CareerPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CareerPlanRepository extends JpaRepository<CareerPlan, Long> {
    Optional<CareerPlan> findByUserIdAndStatus(Long userId, String status);
    
    @Modifying
    @Query("UPDATE CareerPlan cp SET cp.status = 'inactive' WHERE cp.user.id = :userId")
    void deactivateAllUserPlans(@Param("userId") Long userId);
}
