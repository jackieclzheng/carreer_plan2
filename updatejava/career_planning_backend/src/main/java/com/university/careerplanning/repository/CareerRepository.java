package com.university.careerplanning.repository;

import com.university.careerplanning.model.Career;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CareerRepository extends JpaRepository<Career, Long> {
    @Query("SELECT c FROM Career c WHERE " +
           "LOWER(c.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Career> search(@Param("searchTerm") String searchTerm, Pageable pageable);
    
    @Query(value = "SELECT c FROM Career c " +
                  "JOIN c.requiredSkills skill " +
                  "WHERE LOWER(skill) LIKE LOWER(CONCAT('%', :skill, '%'))")
    List<Career> findByRequiredSkill(@Param("skill") String skill);
}