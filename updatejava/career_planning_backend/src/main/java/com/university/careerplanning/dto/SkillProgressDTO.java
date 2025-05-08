
package com.university.careerplanning.dto;

public class SkillProgressDTO {
    private int id;
    private String name;
    private int progress;
    
    public SkillProgressDTO() {}
    
    public SkillProgressDTO(int id, String name, int progress) {
        this.id = id;
        this.name = name;
        this.progress = progress;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }
}

