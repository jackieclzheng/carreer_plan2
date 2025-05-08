package com.university.careerplanning.dto;

import lombok.Data;
import java.util.List;

@Data
public class SemesterPlanDTO {
    private String semester;                                // 学期
    private List<SkillSemesterGoalDTO> skills;            // 技能目标
    private List<SemesterCourseDTO> courses;              // 课程计划
    private List<SemesterCertificateDTO> certificates;    // 证书计划
}