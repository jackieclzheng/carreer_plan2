
package com.university.careerplanning.dto;

public class KeyMetricDTO {
    private int id;
    private String title;
    private int value;
    private int change;
    private String trend;
    
    public KeyMetricDTO() {}
    
    public KeyMetricDTO(int id, String title, int value, int change, String trend) {
        this.id = id;
        this.title = title;
        this.value = value;
        this.change = change;
        this.trend = trend;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public int getValue() { return value; }
    public void setValue(int value) { this.value = value; }
    
    public int getChange() { return change; }
    public void setChange(int change) { this.change = change; }
    
    public String getTrend() { return trend; }
    public void setTrend(String trend) { this.trend = trend; }
}

