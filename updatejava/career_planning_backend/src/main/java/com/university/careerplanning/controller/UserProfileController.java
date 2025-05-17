package com.university.careerplanning.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户资料控制器
 */
@RestController
@RequestMapping("/api/profile")
public class UserProfileController {

    /**
     * 获取用户资料
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserProfile() {
        // 模拟用户资料
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", 2);
        profile.put("username", "user");
        profile.put("email", "user@example.com");
        profile.put("fullName", "张三");
        profile.put("major", "软件工程");
        profile.put("enrollmentYear", "2022");
        profile.put("phone", "13812345678");
        profile.put("avatar", "/images/avatars/user.jpg");
        
        return ResponseEntity.ok(profile);
    }

    /**
     * 更新用户资料
     */
    @PutMapping
    public ResponseEntity<Map<String, Object>> updateUserProfile(@RequestBody Map<String, Object> profileData) {
        // 模拟更新用户资料
        return ResponseEntity.ok(profileData);
    }

    /**
     * 上传头像
     */
    @PostMapping("/avatar")
    public ResponseEntity<Map<String, Object>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        // 模拟文件上传
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("avatarUrl", "/images/avatars/uploaded-" + file.getOriginalFilename());
        
        return ResponseEntity.ok(response);
    }

    /**
     * 修改密码
     */
    @PostMapping("/change-password")
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody Map<String, String> passwordData) {
        String oldPassword = passwordData.get("oldPassword");
        String newPassword = passwordData.get("newPassword");
        
        // 模拟密码修改
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Password changed successfully");
        
        return ResponseEntity.ok(response);
    }
}
