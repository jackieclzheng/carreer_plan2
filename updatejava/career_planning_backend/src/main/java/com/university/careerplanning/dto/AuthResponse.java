package com.university.careerplanning.dto;

public class AuthResponse {
    private String token;
    private Long id;
    private String username;
    private String email;
    private boolean isAdmin;

    // 默认构造函数（可能需要用于序列化/反序列化）
    public AuthResponse() {
    }

    // 现有的构造函数（不要删除它）
    public AuthResponse(String token, Long id, String username, String email) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.email = email;
        this.isAdmin = false; // 默认为非管理员
    }

    // 新增加的带有管理员标志的构造函数
    public AuthResponse(String token, Long id, String username, String email, boolean isAdmin) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.email = email;
        this.isAdmin = isAdmin;
    }

    // Getters and setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }
}