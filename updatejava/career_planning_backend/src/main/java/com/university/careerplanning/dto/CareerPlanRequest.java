package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

@Data
public class CareerPlanRequest {
    private Integer selectedCareer; // 所选职业方向ID
    private String planDuration;    // 规划时长: short, medium, long
    private String skillLevel;      // 技能水平: beginner, intermediate, advanced
    private List<Integer> interests; // 兴趣领域ID列表
    private String weeklyStudyHours; // 每周学习时间: low, medium, high
}
