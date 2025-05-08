package com.university.careerplanning.dto;

import lombok.Data;
import jakarta.validation.constraints.NotNull;
import com.university.careerplanning.dto.SkillStatusUpdateRequest;

@Data
public class SkillStatusUpdateRequest {
    
    @NotNull(message = "学期索引不能为空")
    private Integer semesterIndex;
    
    @NotNull(message = "技能索引不能为空")
    private Integer skillIndex;
    
    @NotNull(message = "新状态不能为空")
    private String newStatus;
}