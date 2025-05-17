package com.university.careerplanning.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.service.QianwenAIService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.util.AssertionErrors.assertFalse;
import static org.springframework.test.util.AssertionErrors.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CareerPlanningController.class)
public class CareerPlanningControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private QianwenAIService qianwenAIService;

    @Autowired
    private ObjectMapper objectMapper;

    private CareerPlanResponse mockResponse;

    @BeforeEach
    public void setup() {
        // 准备模拟的职业规划响应
        mockResponse = new CareerPlanResponse();
        mockResponse.setTargetCareer("前端开发工程师");
        mockResponse.setCareerPath("初级 → 中级 → 高级 → 架构师");
        mockResponse.setEstimatedTime("2-3年");
        mockResponse.setCorePower("UI/UX设计、JavaScript精通");
        mockResponse.setLearningIntensity("标准");
        mockResponse.setSkillLevel("进阶");

        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();
        CareerPlanResponse.Semester semester = new CareerPlanResponse.Semester();
        semester.setSemester("大二上");

        CareerPlanResponse.Skill skill = new CareerPlanResponse.Skill();
        skill.setName("HTML/CSS");
        skill.setSemesterGoal("掌握进阶HTML5和CSS3");
        skill.setStatus("进行中");
        skill.setLearningResources("MDN Web文档");
        semester.setSkills(List.of(skill));

        CareerPlanResponse.Course course = new CareerPlanResponse.Course();
        course.setName("Web前端开发");
        course.setSemester("大二上");
        course.setDifficulty(3);
        course.setEstimatedHours("45");
        semester.setCourses(List.of(course));

        semester.setCertificates(new ArrayList<>());
        semesters.add(semester);
        mockResponse.setSemesters(semesters);

        // 配置模拟服务 - 只为generatePersonalizedPlan方法提供模拟行为
        when(qianwenAIService.generatePersonalizedPlan(any())).thenReturn(mockResponse);
    }

    @Test
    public void testGenerateCareerPlan() throws Exception {
        // 创建请求数据
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1);
        request.setPlanDuration("medium");
        request.setSkillLevel("intermediate");
        request.setInterests(List.of(1, 3));
        request.setWeeklyStudyHours("medium");

        // 执行POST请求测试
        mockMvc.perform(post("/api/career-planning/plan")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.targetCareer").value("前端开发工程师"))
                .andExpect(jsonPath("$.estimatedTime").value("2-3年"))
                .andExpect(jsonPath("$.semesters[0].semester").value("大二上"))
                .andExpect(jsonPath("$.semesters[0].skills[0].name").value("HTML/CSS"));

        // 验证服务方法被调用
        verify(qianwenAIService, times(1)).generatePersonalizedPlan(any());
    }

//    @Test
//    public void testGeneratePersonalizedPlan() {
//        // 创建一个个人信息对象
//        CareerPlanRequest.PersonalInfo personalInfo = new CareerPlanRequest.PersonalInfo();
//        personalInfo.setMajor("计算机科学");
//        personalInfo.setAcademicYear("大二");
//        personalInfo.setLearningStyle("实践型");
//        personalInfo.setCareerGoal("成为优秀的前端开发工程师");
//        personalInfo.setIntensity("适中");
//        personalInfo.setInterests("Web开发, 用户体验");
//        personalInfo.setSkills(Arrays.asList("HTML", "CSS")); // 已掌握的技能
//
//        // 创建职业规划请求
//        CareerPlanRequest request = new CareerPlanRequest();
//        request.setSelectedCareer(1); // 前端开发工程师
//        request.setPersonalInfo(personalInfo);
//
//        // 调用方法
//        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
//
//        // 添加断言验证
//        assertNotNull("职业规划响应不应为空", response);
//        assertNotNull("目标职业不应为空", response.getTargetCareer());
//        assertNotNull("职业发展路径不应为空", response.getCareerPath());
//        assertNotNull("学期规划不应为空", response.getSemesters());
//        assertFalse("学期规划应包含至少一个学期", response.getSemesters().isEmpty());
//
//        // 打印详细信息
//        System.out.println("目标职业: " + response.getTargetCareer());
//        System.out.println("职业路径: " + response.getCareerPath());
//        System.out.println("学期数量: " + response.getSemesters().size());
//
//        // 输出每个学期的详细信息
//        response.getSemesters().forEach(semester -> {
//            System.out.println("\n学期: " + semester.getSemester());
//
//            System.out.println("技能:");
//            semester.getSkills().forEach(skill ->
//                    System.out.println("- " + skill.getName() + ": " + skill.getSemesterGoal() + " (状态: " + skill.getStatus() + ")"));
//
//            System.out.println("课程:");
//            semester.getCourses().forEach(course ->
//                    System.out.println("- " + course.getName()));
//
//            System.out.println("证书:");
//            semester.getCertificates().forEach(cert ->
//                    System.out.println("- " + cert.getName()));
//        });
//    }

    @Test
    void testGeneratePersonalizedPlan() {
        // 创建个人信息
        CareerPlanRequest.PersonalInfo personalInfo = new CareerPlanRequest.PersonalInfo();
        personalInfo.setMajor("计算机科学");
        personalInfo.setAcademicYear("大二");
        personalInfo.setLearningStyle("实践型");
        personalInfo.setCareerGoal("成为前端开发工程师");
        personalInfo.setIntensity("适中");
        personalInfo.setInterests("Web开发");
        personalInfo.setSkills(Arrays.asList("HTML", "CSS"));

        // 创建职业规划请求
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1); // 前端开发工程师
        request.setPersonalInfo(personalInfo);

        // 调用方法
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);

        // 基本断言
//        assertNotNull(response);
//        assertEquals("前端开发工程师", response.getTargetCareer());
//        assertNotNull(response.getSemesters());
//        assertFalse(response.getSemesters().isEmpty());

        // 打印详细信息（可选）
        System.out.println("职业规划详情:");
        System.out.println("目标职业: " + response.getTargetCareer());
        response.getSemesters().forEach(semester -> {
            System.out.println("\n学期: " + semester.getSemester());
            semester.getSkills().forEach(skill ->
                    System.out.println("技能: " + skill.getName() + " - 目标: " + skill.getSemesterGoal())
            );
        });
    }
}