package com.university.careerplanning.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 成绩管理控制器
 * 只包含Controller层，用于前后端分离开发
 */
@RestController
@RequestMapping("/api/admin/grades")
public class AdminGradeController {

    /**
     * 获取所有学生成绩
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllGrades(
            @RequestParam(required = false) String studentName,
            @RequestParam(required = false) String major,
            @RequestParam(required = false) String courseName) {
        
        // 模拟数据
        List<Map<String, Object>> grades = new ArrayList<>();
        
        // 添加模拟数据...
        
        Map<String, Object> response = new HashMap<>();
        response.put("grades", grades);
        response.put("total", grades.size());
        
        return ResponseEntity.ok(response);
    }

    // 其他方法...
}
