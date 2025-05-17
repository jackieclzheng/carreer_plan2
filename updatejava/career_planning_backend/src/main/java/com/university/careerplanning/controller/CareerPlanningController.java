package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.dto.SkillUpdateRequest;
import com.university.careerplanning.service.QianwenAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/career-planning")
@CrossOrigin(origins = "*") // 允许跨域请求
public class CareerPlanningController {
    
    @Autowired
    private QianwenAIService qianwenAIService;
    
    @PostMapping("/plan")
    public ResponseEntity<CareerPlanResponse> generateCareerPlan(@RequestBody CareerPlanRequest request) {
        // 调用通义千问服务生成职业规划
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/directions")
    public ResponseEntity<?> getCareerDirections() {
        // 返回预定义的职业方向列表
        return ResponseEntity.ok(qianwenAIService.getCareerDirections());
    }
    
    @PatchMapping("/plan/skills")
    public ResponseEntity<?> updateSkillStatus(@RequestBody SkillUpdateRequest request) {
        // 存储用户技能状态更新（可以保存到数据库）
        qianwenAIService.updateSkillStatus(request);
        return ResponseEntity.ok().build();
    }
}
