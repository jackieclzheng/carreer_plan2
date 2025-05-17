package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

/**
 * 职业规划请求DTO
 */
@Data
public class CareerPlanRequest {
    private Integer selectedCareer; // 所选职业方向ID
    private PersonalInfo personalInfo; // 个人信息对象

    // 兼容旧版本的字段
    private String planDuration;    // 规划时长: short, medium, long
    private String skillLevel;      // 技能水平: beginner, intermediate, advanced
    private List<Integer> interests; // 兴趣领域ID列表
    private String weeklyStudyHours; // 每周学习时间: low, medium, high

    /**
     * 个人信息内部类
     */
    @Data
    public static class PersonalInfo {
        private String major;           // 专业背景
        private String academicYear;    // 当前学年
        private List<String> skills;    // 已掌握技能列表
        private String learningStyle;   // 学习风格偏好
        private String careerGoal;      // 职业发展目标
        private String intensity;       // 学习强度
        private String interests;       // 兴趣领域
    }
}