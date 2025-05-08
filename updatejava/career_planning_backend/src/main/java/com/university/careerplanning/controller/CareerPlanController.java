package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerDirectionDTO;
import com.university.careerplanning.dto.CareerPlanDTO;
import com.university.careerplanning.dto.SkillStatusUpdateRequest;
import com.university.careerplanning.model.CareerPlan;
import com.university.careerplanning.service.CareerPlanService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/career-planning")
public class CareerPlanController {

    @Autowired
    private CareerPlanService careerPlanService;
    
    @Autowired
    private UserService userService;

    @GetMapping("/directions")
    public ResponseEntity<List<CareerDirectionDTO>> getCareerDirections() {
        // 返回预定义的职业方向
        List<CareerDirectionDTO> directions = careerPlanService.getAllCareerDirections();
        return ResponseEntity.ok(directions);
    }

    @GetMapping("/plan")
    public ResponseEntity<CareerPlanDTO> getPersonalizedPlan(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        CareerPlanDTO plan = careerPlanService.getPersonalizedPlan(userId);
        return ResponseEntity.ok(plan);
    }

    @PostMapping("/plan")
    public ResponseEntity<CareerPlanDTO> generatePersonalizedPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CareerPlanRequest request) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        CareerPlanDTO plan = careerPlanService.generatePersonalizedPlan(userId, request.getSelectedCareer());
        return ResponseEntity.ok(plan);
    }

    @PatchMapping("/plan/skills")
    public ResponseEntity<CareerPlanDTO> updateSkillStatus(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody SkillStatusUpdateRequest request) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        CareerPlanDTO updatedPlan = careerPlanService.updateSkillStatus(
                userId, 
                request.getSemesterIndex(), 
                request.getSkillIndex(), 
                request.getNewStatus()
        );
        
        return ResponseEntity.ok(updatedPlan);
    }
    
    // 内部请求类
    public static class CareerPlanRequest {
        private Integer selectedCareer;
        
        // Getter and Setter
        public Integer getSelectedCareer() { return selectedCareer; }
        public void setSelectedCareer(Integer selectedCareer) { this.selectedCareer = selectedCareer; }
    }
}