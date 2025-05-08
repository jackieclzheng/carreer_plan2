
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;

public class CertificateDTO {
    private Long id;
    
    @NotBlank(message = "证书名称不能为空")
    private String name;
    
    @NotBlank(message = "颁发机构不能为空")
    private String issuer;
    
    @NotBlank(message = "获取日期不能为空")
    private String date;
    
    private String type;
    
    private String fileUrl;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getIssuer() { return issuer; }
    public void setIssuer(String issuer) { this.issuer = issuer; }
    
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
}

