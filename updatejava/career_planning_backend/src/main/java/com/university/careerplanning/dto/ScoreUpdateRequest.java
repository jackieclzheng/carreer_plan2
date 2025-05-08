
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class ScoreUpdateRequest {
    @Min(value = 0, message = "成绩不能小于0")
    @Max(value = 100, message = "成绩不能大于100")
    private int score;
    
    // Getter and Setter
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
}

