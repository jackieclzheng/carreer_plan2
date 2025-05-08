package com.university.careerplanning.dto;

import lombok.Data;

@Data
public class SkillSemesterGoalDTO {
    private String name;            // 技能名称
    private String semesterGoal;    // 学期目标
    private String status;          // 技能状态（未开始/进行中/已完成）
}