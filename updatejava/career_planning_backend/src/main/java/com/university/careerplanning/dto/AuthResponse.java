
package com.university.careerplanning.dto;

public class AuthResponse {
    private String token;
    private Long id;
    private String username;
    private String email;

    public AuthResponse(String token, Long id, String username, String email) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.email = email;
    }

    // Getters
    public String getToken() { return token; }
    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
}

