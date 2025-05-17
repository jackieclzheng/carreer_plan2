package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerDirectionDTO;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.dto.SkillUpdateRequest;
import com.university.careerplanning.service.QianwenAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/career-planning")
@CrossOrigin(origins = "*") // 允许跨域请求
public class CareerPlanningController {

    @Autowired
    private QianwenAIService qianwenAIService;

    /**
     * 生成职业规划
     * 接受包含个性化信息的请求，生成定制化职业规划
     */
    @PostMapping("/plan")
    public ResponseEntity<CareerPlanResponse> generateCareerPlan(@RequestBody @Validated CareerPlanRequest request) {
        // 验证请求中的必要字段
        if (request.getSelectedCareer() == null) {
            return ResponseEntity.badRequest().build();
        }

        // 调用通义千问服务生成职业规划
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        return ResponseEntity.ok(response);
    }

    /**
     * 获取所有可用的职业方向
     * 返回预定义的职业方向列表，供前端选择
     */
    @GetMapping("/directions")
    public ResponseEntity<List<CareerDirectionDTO>> getCareerDirections() {
        // 返回预定义的职业方向列表
        List<CareerDirectionDTO> directions = qianwenAIService.getCareerDirections();
        return ResponseEntity.ok(directions);
    }

    /**
     * 更新技能状态
     * 更新特定学期中特定技能的状态
     */
    @PatchMapping("/plan/skills")
    public ResponseEntity<?> updateSkillStatus(@RequestBody @Validated SkillUpdateRequest request) {
        // 验证状态值是否有效
        if (!isValidStatus(request.getNewStatus())) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("无效的状态值。有效值: '未开始', '进行中', '已完成'");
        }

        // 存储用户技能状态更新
        qianwenAIService.updateSkillStatus(request);
        return ResponseEntity.ok().build();
    }

    /**
     * 添加新端点：生成高度个性化的职业规划
     * 专门处理带有丰富个性化信息的请求
     */
    @PostMapping("/personalized-plan")
    public ResponseEntity<CareerPlanResponse> generatePersonalizedPlan(@RequestBody @Validated CareerPlanRequest request) {
        // 验证个性化信息
        if (request.getPersonalInfo() == null) {
            return ResponseEntity.badRequest().body(null);
        }

        // 调用通义千问服务生成个性化职业规划
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        return ResponseEntity.ok(response);
    }

    /**
     * 验证技能状态值是否有效
     */
    private boolean isValidStatus(String status) {
        return status != null &&
                (status.equals("未开始") ||
                        status.equals("进行中") ||
                        status.equals("已完成"));
    }
}