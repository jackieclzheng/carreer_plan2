package com.university.careerplanning.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @GetMapping
    public ResponseEntity<Map<String, Object>> getDashboard() {
        System.out.println("DashboardController: GET请求已接收");

        // 创建一个包含所有Dashboard数据的Map
        Map<String, Object> dashboardData = new HashMap<>();

        // 1. 设置整体进度
        dashboardData.put("overallProgress", 45);

        // 2. 设置当前目标
        dashboardData.put("currentGoal", "成为优秀的软件开发工程师");

        // 3. 关键指标
        List<Map<String, Object>> keyMetrics = new ArrayList<>();

        Map<String, Object> metric1 = new HashMap<>();
        metric1.put("icon", "book");
        metric1.put("title", "累计学习课程");
        metric1.put("value", 12);
        metric1.put("color", "bg-blue-100 text-blue-600");
        keyMetrics.add(metric1);

        Map<String, Object> metric2 = new HashMap<>();
        metric2.put("icon", "trophy");
        metric2.put("title", "获得证书");
        metric2.put("value", 3);
        metric2.put("color", "bg-green-100 text-green-600");
        keyMetrics.add(metric2);

        Map<String, Object> metric3 = new HashMap<>();
        metric3.put("icon", "star");
        metric3.put("title", "完成项目");
        metric3.put("value", 5);
        metric3.put("color", "bg-purple-100 text-purple-600");
        keyMetrics.add(metric3);

        dashboardData.put("keyMetrics", keyMetrics);

        // 4. 技能进度
        List<Map<String, Object>> skillProgress = new ArrayList<>();

        Map<String, Object> skill1 = new HashMap<>();
        skill1.put("name", "JavaScript");
        skill1.put("progress", 75);
        skillProgress.add(skill1);

        Map<String, Object> skill2 = new HashMap<>();
        skill2.put("name", "React");
        skill2.put("progress", 60);
        skillProgress.add(skill2);

        Map<String, Object> skill3 = new HashMap<>();
        skill3.put("name", "Java");
        skill3.put("progress", 50);
        skillProgress.add(skill3);

        dashboardData.put("skillProgress", skillProgress);

        // 5. 最近活动
        List<Map<String, Object>> recentActivities = new ArrayList<>();

        Map<String, Object> activity1 = new HashMap<>();
        activity1.put("title", "完成React高级课程");
        activity1.put("date", "2024-03-15");
        activity1.put("type", "学习");
        recentActivities.add(activity1);

        Map<String, Object> activity2 = new HashMap<>();
        activity2.put("title", "获得JavaWeb开发证书");
        activity2.put("date", "2024-02-20");
        activity2.put("type", "认证");
        recentActivities.add(activity2);

        Map<String, Object> activity3 = new HashMap<>();
        activity3.put("title", "参加全国软件开发大赛");
        activity3.put("date", "2024-01-10");
        activity3.put("type", "竞赛");
        recentActivities.add(activity3);

        dashboardData.put("recentActivities", recentActivities);

//        System.out.println("DashboardController: 返回模拟数据");
        return ResponseEntity.ok(dashboardData);
    }
}