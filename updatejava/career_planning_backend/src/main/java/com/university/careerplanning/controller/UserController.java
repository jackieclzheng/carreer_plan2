
package com.university.careerplanning.controller;

import com.university.careerplanning.model.User;
import com.university.careerplanning.service.UserService;
import com.university.careerplanning.dto.RegisterRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
        User registeredUser = userService.registerNewUser(registerRequest);
        return ResponseEntity.ok(registeredUser);
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile() {
        // 这里应该从安全上下文获取当前用户
        // 实际应用中需要实现更复杂的用户获取逻辑
        return ResponseEntity.ok("用户资料");
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(@RequestBody User user) {
        User updatedUser = userService.updateUser(user);
        return ResponseEntity.ok(updatedUser);
    }
}

