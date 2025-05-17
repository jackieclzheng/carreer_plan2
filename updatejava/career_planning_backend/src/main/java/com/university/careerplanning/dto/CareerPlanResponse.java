package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

/**
 * 职业规划响应DTO
 */
@Data
public class CareerPlanResponse {
    // 核心职业信息
    private String targetCareer;      // 目标职业
    private String careerGoal;        // 职业目标

    // 个人背景信息
    private String majorBackground;   // 专业背景
    private String learningStyle;     // 学习风格
    private String intensity;         // 学习强度
    private String interests;         // 兴趣领域

    // 兼容旧版本的字段
    private String careerPath;        // 职业发展路径
    private String estimatedTime;     // 预计达成时间
    private String corePower;         // 核心竞争力
    private String learningIntensity; // 学习强度（旧字段）
    private String skillLevel;        // 技能水平

    // 学期规划
    private List<Semester> semesters; // 学期规划列表

    @Data
    public static class Semester {
        private String semester;              // 学期名称
        private List<Skill> skills;           // 技能列表
        private List<Course> courses;         // 课程列表
        private List<Certificate> certificates; // 证书列表
    }

    @Data
    public static class Skill {
        private String name;           // 技能名称
        private String semesterGoal;   // 本学期目标
        private String status;         // 技能状态：未开始、进行中、已完成
        private String learningResources; // 学习资源（可选）
    }

    @Data
    public static class Course {
        private String name;           // 课程名称
        private String semester;       // 建议学期
        private Integer difficulty;    // 难度级别（可选）
        private String estimatedHours; // 预计学时（可选）
    }

    @Data
    public static class Certificate {
        private String name;           // 证书名称
        private String semester;       // 建议学期
        private String recognition;    // 认可度（可选）
        private String cost;           // 费用（可选）
    }
}