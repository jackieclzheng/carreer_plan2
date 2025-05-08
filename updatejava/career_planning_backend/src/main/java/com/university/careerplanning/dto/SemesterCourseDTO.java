package com.university.careerplanning.dto;

import lombok.Data;

@Data
public class SemesterCourseDTO {
    private String name;        // 课程名称
    private String semester;    // 所属学期
    private String description; // 课程描述
    private Integer credits;    // 学分
}