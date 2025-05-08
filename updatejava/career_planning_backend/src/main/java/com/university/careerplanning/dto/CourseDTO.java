
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public class CourseDTO {
    private Long id;
    
    @NotBlank(message = "课程名称不能为空")
    private String name;
    
    @NotBlank(message = "学期不能为空")
    private String semester;
    
    @Min(value = 0, message = "成绩不能小于0")
    @Max(value = 100, message = "成绩不能大于100")
    private int score;
    
    @Positive(message = "学分必须为正数")
    private int credits;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }
    
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    
    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }
}

