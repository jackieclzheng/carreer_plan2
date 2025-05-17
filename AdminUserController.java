package com.university.careerplanning.controller;

import com.university.careerplanning.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户管理控制器
 * 只包含Controller层，用于前后端分离开发
 */
@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    /**
     * 获取所有用户列表
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllUsers() {
        // 模拟数据
        List<Map<String, Object>> users = new ArrayList<>();
        
        Map<String, Object> admin = new HashMap<>();
        admin.put("id", 1);
        admin.put("username", "admin");
        admin.put("email", "admin@example.com");
        admin.put("major", "计算机科学");
        admin.put("enrollmentYear", "2022");
        admin.put("role", "admin");
        admin.put("active", true);
        
        Map<String, Object> student1 = new HashMap<>();
        student1.put("id", 2);
        student1.put("username", "zhang_san");
        student1.put("email", "zhang_san@example.com");
        student1.put("major", "软件工程");
        student1.put("enrollmentYear", "2022");
        student1.put("role", "student");
        student1.put("active", true);
        
        Map<String, Object> student2 = new HashMap<>();
        student2.put("id", 3);
        student2.put("username", "li_si");
        student2.put("email", "li_si@example.com");
        student2.put("major", "人工智能");
        student2.put("enrollmentYear", "2023");
        student2.put("role", "student");
        student2.put("active", true);
        
        Map<String, Object> student3 = new HashMap<>();
        student3.put("id", 4);
        student3.put("username", "wang_wu");
        student3.put("email", "wang_wu@example.com");
        student3.put("major", "数据科学");
        student3.put("enrollmentYear", "2021");
        student3.put("role", "student");
        student3.put("active", false);
        
        users.add(admin);
        users.add(student1);
        users.add(student2);
        users.add(student3);
        
        Map<String, Object> response = new HashMap<>();
        response.put("users", users);
        response.put("total", users.size());
        
        return ResponseEntity.ok(response);
    }

    // 其他方法...
}
