
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;

public class GoalUpdateRequest {
    @NotBlank(message = "目标不能为空")
    private String goal;
    
    public GoalUpdateRequest() {}
    
    public GoalUpdateRequest(String goal) {
        this.goal = goal;
    }
    
    // Getter and Setter
    public String getGoal() { return goal; }
    public void setGoal(String goal) { this.goal = goal; }
}

