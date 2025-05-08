
package com.university.careerplanning.dto;

public class RecentActivityDTO {
    private int id;
    private String title;
    private String date;
    private String type;
    
    public RecentActivityDTO() {}
    
    public RecentActivityDTO(int id, String title, String date, String type) {
        this.id = id;
        this.title = title;
        this.date = date;
        this.type = type;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
}

