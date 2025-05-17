package com.university.careerplanning.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.dto.SkillUpdateRequest;
import com.university.careerplanning.service.QianwenAIService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
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

        // 配置模拟服务
        when(qianwenAIService.generatePersonalizedPlan(any())).thenReturn(mockResponse);
        when(qianwenAIService.getCareerDirections()).thenReturn(List.of(
                Map.of("id", 1, "title", "前端开发工程师", "description", "专注于Web前端开发技术")
        ));
        doNothing().when(qianwenAIService).updateSkillStatus(any());
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

    @Test
    public void testGetCareerDirections() throws Exception {
        // 执行GET请求测试
        mockMvc.perform(get("/api/career-planning/directions"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].title").value("前端开发工程师"));

        // 验证服务方法被调用
        verify(qianwenAIService, times(1)).getCareerDirections();
    }

    @Test
    public void testUpdateSkillStatus() throws Exception {
        // 创建请求数据
        SkillUpdateRequest request = new SkillUpdateRequest();
        request.setSemesterIndex(0);
        request.setSkillIndex(0);
        request.setNewStatus("已完成");

        // 执行PATCH请求测试
        mockMvc.perform(patch("/api/career-planning/plan/skills")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        // 验证服务方法被调用
        verify(qianwenAIService, times(1)).updateSkillStatus(any());
    }
}
