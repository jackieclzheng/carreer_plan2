package com.university.careerplanning.dto;

import lombok.Data;

@Data
public class SemesterCertificateDTO {
    private String name;            // 证书名称
    private String description;     // 证书描述
    private String semester;        // 建议获取学期
    private String difficulty;      // 难度级别
    private String importance;      // 重要程度
}