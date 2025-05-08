
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotNull;

public class SaveCareerRequest {
    @NotNull(message = "职业ID不能为空")
    private Long careerId;
    
    // Getter and Setter
    public Long getCareerId() { return careerId; }
    public void setCareerId(Long careerId) { this.careerId = careerId; }
}

