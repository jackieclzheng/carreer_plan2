
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Career;
import com.university.careerplanning.model.SavedCareer;
import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SavedCareerRepository extends JpaRepository<SavedCareer, Long> {
    List<SavedCareer> findByUser(User user);
    Optional<SavedCareer> findByUserAndCareer(User user, Career career);
    boolean existsByUserAndCareer(User user, Career career);
}

