package com.university.careerplanning.dto;

import java.util.List;
import com.university.careerplanning.dto.SkillSemesterGoalDTO;
import com.university.careerplanning.dto.SemesterCourseDTO;

public class CareerDirectionDTO {
    private int id;
    private String title;
    private List<SkillSemesterGoalDTO> recommendedSkills;
    private List<SemesterCourseDTO> recommendedCourses;
    private List<SemesterCertificateDTO> recommendedCertificates;
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public List<SkillSemesterGoalDTO> getRecommendedSkills() { return recommendedSkills; }
    public void setRecommendedSkills(List<SkillSemesterGoalDTO> recommendedSkills) { this.recommendedSkills = recommendedSkills; }
    
    public List<SemesterCourseDTO> getRecommendedCourses() { return recommendedCourses; }
    public void setRecommendedCourses(List<SemesterCourseDTO> recommendedCourses) { this.recommendedCourses = recommendedCourses; }
    
    public List<SemesterCertificateDTO> getRecommendedCertificates() { return recommendedCertificates; }
    public void setRecommendedCertificates(List<SemesterCertificateDTO> recommendedCertificates) { this.recommendedCertificates = recommendedCertificates; }
}

