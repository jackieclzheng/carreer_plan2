
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class ProgressUpdateRequest {
    @Min(value = 0, message = "进度不能小于0")
    @Max(value = 100, message = "进度不能大于100")
    private int progress;
    
    // Getter and Setter
    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }
}

