package com.university.careerplanning.dto;

import lombok.Data;

/**
 * 技能状态更新请求DTO
 */
@Data
public class SkillUpdateRequest {
    private int semesterIndex;  // 学期在数组中的索引
    private int skillIndex;     // 技能在学期技能数组中的索引
    private String newStatus;   // 新状态值: 未开始、进行中、已完成
}