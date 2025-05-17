package com.university.careerplanning.dto;

import lombok.Data;

@Data
public class SkillUpdateRequest {
    private int semesterIndex;
    private int skillIndex;
    private String newStatus;
}
