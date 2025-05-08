package com.university.careerplanning.dto;

import lombok.Data;
import java.util.List;

@Data
public class CareerPlanDTO {
    private String targetCareer;                    // 目标职业
    private List<SemesterPlanDTO> semesters;       // 学期计划列表
}