
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class BatchStatusUpdateRequest {
    @NotEmpty(message = "任务ID列表不能为空")
    private List<Long> ids;
    
    @NotBlank(message = "状态不能为空")
    private String status;
    
    // Getters and Setters
    public List<Long> getIds() { return ids; }
    public void setIds(List<Long> ids) { this.ids = ids; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

