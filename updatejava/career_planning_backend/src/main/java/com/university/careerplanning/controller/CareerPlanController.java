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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

//    @GetMapping("/plan")
//    public ResponseEntity<CareerPlanDTO> getPersonalizedPlan(@AuthenticationPrincipal UserDetails userDetails) {
//        Long userId = userService.findByUsername(userDetails.getUsername())
//                .orElseThrow(() -> new RuntimeException("用户未找到"))
//                .getId();
//
//        CareerPlanDTO plan = careerPlanService.getPersonalizedPlan(userId);
//        return ResponseEntity.ok(plan);
//    }

    @GetMapping("/plan")
    public ResponseEntity<Map<String, Object>> getPersonalizedPlan() {
        // 不再使用@AuthenticationPrincipal和UserDetails
        // 直接返回硬编码的假数据

        // 创建一个包含职业规划数据的Map
        Map<String, Object> plan = new HashMap<>();
        plan.put("targetCareer", "全栈开发工程师");

        // 创建学期列表
        List<Map<String, Object>> semesters = new ArrayList<>();

        // 第一学期
        Map<String, Object> semester1 = new HashMap<>();
        semester1.put("semester", "大二上");

        // 技能1
        List<Map<String, Object>> skills1 = new ArrayList<>();
        Map<String, Object> skill1 = new HashMap<>();
        skill1.put("name", "编程基础");
        skill1.put("semesterGoal", "掌握编程基本概念");
        skill1.put("status", "进行中");
        skills1.add(skill1);
        semester1.put("skills", skills1);

        // 课程1
        List<Map<String, Object>> courses1 = new ArrayList<>();
        Map<String, Object> course1 = new HashMap<>();
        course1.put("name", "程序设计基础");
        course1.put("semester", "大二上");
        courses1.add(course1);
        semester1.put("courses", courses1);

        // 空证书列表
        semester1.put("certificates", new ArrayList<>());

        // 将第一学期添加到学期列表
        semesters.add(semester1);

        // 第二学期
        Map<String, Object> semester2 = new HashMap<>();
        semester2.put("semester", "大二下");

        // 技能2
        List<Map<String, Object>> skills2 = new ArrayList<>();
        Map<String, Object> skill2 = new HashMap<>();
        skill2.put("name", "算法与数据结构");
        skill2.put("semesterGoal", "学习常用算法");
        skill2.put("status", "未开始");
        skills2.add(skill2);
        semester2.put("skills", skills2);

        // 课程2
        List<Map<String, Object>> courses2 = new ArrayList<>();
        Map<String, Object> course2 = new HashMap<>();
        course2.put("name", "数据结构与算法");
        course2.put("semester", "大二下");
        courses2.add(course2);
        semester2.put("courses", courses2);

        // 空证书列表
        semester2.put("certificates", new ArrayList<>());

        // 将第二学期添加到学期列表
        semesters.add(semester2);

        // 第三学期
        Map<String, Object> semester3 = new HashMap<>();
        semester3.put("semester", "大三上");

        // 技能3
        List<Map<String, Object>> skills3 = new ArrayList<>();
        Map<String, Object> skill3 = new HashMap<>();
        skill3.put("name", "专业领域技能");
        skill3.put("semesterGoal", "掌握专业技术");
        skill3.put("status", "未开始");
        skills3.add(skill3);
        semester3.put("skills", skills3);

        // 空课程列表
        semester3.put("courses", new ArrayList<>());

        // 证书
        List<Map<String, Object>> certificates = new ArrayList<>();
        Map<String, Object> cert = new HashMap<>();
        cert.put("name", "软件开发工程师认证");
        cert.put("semester", "大三上");
        certificates.add(cert);
        semester3.put("certificates", certificates);

        // 将第三学期添加到学期列表
        semesters.add(semester3);

        // 添加学期列表到计划
        plan.put("semesters", semesters);

        return ResponseEntity.ok(plan);
    }

    @PostMapping("/plan")
    public ResponseEntity<Map<String, Object>> generatePersonalizedPlan(
            @RequestBody Map<String, Object> request) {
        // 从请求中获取选择的职业ID
        Integer selectedCareer = (Integer) request.get("selectedCareer");
        if (selectedCareer == null) {
            return ResponseEntity.badRequest().build();
        }

        // 根据选择的职业ID返回不同的假数据
        Map<String, Object> plan = new HashMap<>();

        // 设置目标职业
        String targetCareer;
        if (selectedCareer == 1) {
            targetCareer = "前端开发工程师";
        } else if (selectedCareer == 2) {
            targetCareer = "Java后端工程师";
        } else if (selectedCareer == 3) {
            targetCareer = "Python开发工程师";
        } else if (selectedCareer == 4) {
            targetCareer = "全栈开发工程师";
        } else if (selectedCareer == 5) {
            targetCareer = "数据工程师";
        } else if (selectedCareer == 6) {
            targetCareer = "DevOps工程师";
        } else {
            targetCareer = "软件工程师";
        }
        plan.put("targetCareer", targetCareer);

        // 创建学期列表
        List<Map<String, Object>> semesters = new ArrayList<>();

        // 第一学期
        Map<String, Object> semester1 = new HashMap<>();
        semester1.put("semester", "大二上");

        // 技能1
        List<Map<String, Object>> skills1 = new ArrayList<>();
        Map<String, Object> skill1 = new HashMap<>();
        if (selectedCareer == 1) { // 前端
            skill1.put("name", "HTML/CSS");
            skill1.put("semesterGoal", "掌握HTML5和CSS3基础");
        } else if (selectedCareer == 2) { // Java后端
            skill1.put("name", "Java基础");
            skill1.put("semesterGoal", "掌握Java核心语法");
        } else {
            skill1.put("name", "编程基础");
            skill1.put("semesterGoal", "掌握编程基本概念");
        }
        skill1.put("status", "进行中");
        skills1.add(skill1);
        semester1.put("skills", skills1);

        // 课程1
        List<Map<String, Object>> courses1 = new ArrayList<>();
        Map<String, Object> course1 = new HashMap<>();
        if (selectedCareer == 1) {
            course1.put("name", "Web前端开发基础");
        } else if (selectedCareer == 2) {
            course1.put("name", "Java程序设计");
        } else {
            course1.put("name", "程序设计基础");
        }
        course1.put("semester", "大二上");
        courses1.add(course1);
        semester1.put("courses", courses1);

        // 空证书列表
        semester1.put("certificates", new ArrayList<>());

        // 将第一学期添加到学期列表
        semesters.add(semester1);

        // 第二学期
        Map<String, Object> semester2 = new HashMap<>();
        semester2.put("semester", "大二下");

        // 技能2
        List<Map<String, Object>> skills2 = new ArrayList<>();
        Map<String, Object> skill2 = new HashMap<>();
        if (selectedCareer == 1) {
            skill2.put("name", "JavaScript");
            skill2.put("semesterGoal", "掌握JavaScript和DOM编程");
        } else if (selectedCareer == 2) {
            skill2.put("name", "Spring框架");
            skill2.put("semesterGoal", "学习Spring Boot开发");
        } else {
            skill2.put("name", "算法与数据结构");
            skill2.put("semesterGoal", "学习常用算法");
        }
        skill2.put("status", "未开始");
        skills2.add(skill2);
        semester2.put("skills", skills2);

        // 课程2
        List<Map<String, Object>> courses2 = new ArrayList<>();
        Map<String, Object> course2 = new HashMap<>();
        if (selectedCareer == 1) {
            course2.put("name", "JavaScript编程");
        } else if (selectedCareer == 2) {
            course2.put("name", "Spring框架入门");
        } else {
            course2.put("name", "数据结构与算法");
        }
        course2.put("semester", "大二下");
        courses2.add(course2);
        semester2.put("courses", courses2);

        // 空证书列表
        semester2.put("certificates", new ArrayList<>());

        // 将第二学期添加到学期列表
        semesters.add(semester2);

        // 第三学期
        Map<String, Object> semester3 = new HashMap<>();
        semester3.put("semester", "大三上");

        // 技能3
        List<Map<String, Object>> skills3 = new ArrayList<>();
        Map<String, Object> skill3 = new HashMap<>();
        if (selectedCareer == 1) {
            skill3.put("name", "前端框架");
            skill3.put("semesterGoal", "学习React/Vue等主流框架");
        } else if (selectedCareer == 2) {
            skill3.put("name", "数据库设计");
            skill3.put("semesterGoal", "掌握SQL和数据库优化");
        } else {
            skill3.put("name", "专业领域技能");
            skill3.put("semesterGoal", "掌握专业技术");
        }
        skill3.put("status", "未开始");
        skills3.add(skill3);
        semester3.put("skills", skills3);

        // 空课程列表
        semester3.put("courses", new ArrayList<>());

        // 证书
        List<Map<String, Object>> certificates = new ArrayList<>();
        Map<String, Object> cert = new HashMap<>();
        if (selectedCareer == 1) {
            cert.put("name", "前端开发工程师认证");
        } else if (selectedCareer == 2) {
            cert.put("name", "Java工程师认证");
        } else {
            cert.put("name", "软件开发工程师认证");
        }
        cert.put("semester", "大三上");
        certificates.add(cert);
        semester3.put("certificates", certificates);

        // 将第三学期添加到学期列表
        semesters.add(semester3);

        // 添加学期列表到计划
        plan.put("semesters", semesters);

        return ResponseEntity.ok(plan);
    }

//    @PatchMapping("/plan/skills")
//    public ResponseEntity<Map<String, Object>> updateSkillStatus(
//            @RequestBody Map<String, Object> request) {
//        // 收到更新请求后，直接返回成功响应
//        // 不进行实际的数据更新
//        Map<String, Object> response = new HashMap<>();
//        response.put("success", true);
//        response.put("message", "技能状态已更新");
//
//        return ResponseEntity.ok(response);
//    }

    // 添加到CareerPlanService中的新方法
    public CareerPlanDTO getAnonymousPersonalizedPlan() {
        // 实现匿名用户的职业规划逻辑
        // 可以返回一个通用模板或空规划
        CareerPlanDTO plan = new CareerPlanDTO();
        // 设置基本信息...
        return plan;
    }

//    @PostMapping("/plan")
//    public ResponseEntity<CareerPlanDTO> generatePersonalizedPlan(
//            @AuthenticationPrincipal UserDetails userDetails,
//            @Valid @RequestBody CareerPlanRequest request) {
//
//        Long userId = userService.findByUsername(userDetails.getUsername())
//                .orElseThrow(() -> new RuntimeException("用户未找到"))
//                .getId();
//
//        CareerPlanDTO plan = careerPlanService.generatePersonalizedPlan(userId, request.getSelectedCareer());
//        return ResponseEntity.ok(plan);
//    }

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