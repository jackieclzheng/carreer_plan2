package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

@Data
public class CareerPlanResponse {
    private String targetCareer;      // 目标职业
    private String careerPath;        // 职业发展路径
    private String estimatedTime;     // 预计达成时间
    private String corePower;         // 核心竞争力
    private String learningIntensity; // 学习强度
    private String skillLevel;        // 技能水平
    private List<Semester> semesters; // 学期规划列表
    
    @Data
    public static class Semester {
        private String semester;
        private List<Skill> skills;
        private List<Course> courses;
        private List<Certificate> certificates;
    }
    
    @Data
    public static class Skill {
        private String name;
        private String semesterGoal;
        private String status;
        private String learningResources;
    }
    
    @Data
    public static class Course {
        private String name;
        private String semester;
        private int difficulty;
        private String estimatedHours;
    }
    
    @Data
    public static class Certificate {
        private String name;
        private String semester;
        private String recognition;
        private String cost;
    }
}
