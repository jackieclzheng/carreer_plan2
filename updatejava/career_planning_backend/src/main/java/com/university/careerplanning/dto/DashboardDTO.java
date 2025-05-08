
package com.university.careerplanning.dto;

import java.util.List;

public class DashboardDTO {
    private int overallProgress;
    private String currentGoal;
    private List<KeyMetricDTO> keyMetrics;
    private List<SkillProgressDTO> skillProgress;
    private List<RecentActivityDTO> recentActivities;
    
    // Getters and Setters
    public int getOverallProgress() { return overallProgress; }
    public void setOverallProgress(int overallProgress) { this.overallProgress = overallProgress; }
    
    public String getCurrentGoal() { return currentGoal; }
    public void setCurrentGoal(String currentGoal) { this.currentGoal = currentGoal; }
    
    public List<KeyMetricDTO> getKeyMetrics() { return keyMetrics; }
    public void setKeyMetrics(List<KeyMetricDTO> keyMetrics) { this.keyMetrics = keyMetrics; }
    
    public List<SkillProgressDTO> getSkillProgress() { return skillProgress; }
    public void setSkillProgress(List<SkillProgressDTO> skillProgress) { this.skillProgress = skillProgress; }
    
    public List<RecentActivityDTO> getRecentActivities() { return recentActivities; }
    public void setRecentActivities(List<RecentActivityDTO> recentActivities) { this.recentActivities = recentActivities; }
}

