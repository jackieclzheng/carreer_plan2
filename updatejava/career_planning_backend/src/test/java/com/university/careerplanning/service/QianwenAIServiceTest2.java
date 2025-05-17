package com.university.careerplanning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
//import com.university.careerplanning.dto.PersonalInfo;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@SpringBootTest
public class QianwenAIServiceTest2 {
    private static final Logger logger = LoggerFactory.getLogger(QianwenAIServiceTest2.class);

    @Autowired
    private QianwenAIService qianwenAIService;

//    @Autowired
//    private RestTemplate restTemplate;

    @Mock
    private RestTemplate restTemplate;

    @Value("${qianwen.api.key}")
    private String apiKey;

    @Value("${qianwen.api.url}")
    private String apiUrl;

    private ObjectMapper objectMapper;

    @BeforeEach
    void setup() {
        objectMapper = new ObjectMapper();

        // 详细打印配置信息
        logger.info("=== Qianwen API 配置详情 ===");
        logger.info("API Key: {}", apiKey);
        logger.info("API URL: {}", apiUrl);
        logger.info("API Key Length: {}", apiKey.length());
        logger.info("API Key Prefix: {}", apiKey.substring(0, Math.min(10, apiKey.length())));
    }

    @Test
    void testGeneratePersonalizedPlanManualApiCall() {
        try {
            // 创建请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            // 构建请求体
            String prompt = "请为一个前端开发方向的学生生成一份个性化职业规划，包括技能学习路径、推荐课程和证书。";

            // 创建请求对象
            QianwenAIService.QianwenRequest qianwenRequest = new QianwenAIService.QianwenRequest();
            qianwenRequest.setModel("qwen-plus");
            qianwenRequest.setInput(new QianwenAIService.QianwenInput(prompt));

            // 创建 HTTP 实体
            HttpEntity<QianwenAIService.QianwenRequest> requestEntity =
                    new HttpEntity<>(qianwenRequest, headers);

            // 打印请求详情
            logger.info("=== 请求详情 ===");
            logger.info("请求URL: {}", apiUrl);
            logger.info("请求头: {}", headers);
            logger.info("请求体: {}", objectMapper.writeValueAsString(qianwenRequest));

            // 发送请求
            QianwenAIService.QianwenResponse response = restTemplate.postForObject(
                    apiUrl,
                    requestEntity,
                    QianwenAIService.QianwenResponse.class
            );

            // 验证响应
            assertNotNull(response, "API响应不应为空");
            assertNotNull(response.getOutput(), "响应Output不应为空");

            // 打印响应
            logger.info("=== 响应详情 ===");
            logger.info("响应文本: {}", response.getOutput().getText());

        } catch (Exception e) {
            logger.error("API调用异常", e);
            fail("API调用失败: " + e.getMessage());
        }
    }

    @Test
    void testGeneratePersonalizedPlan() {
        try {
            // 创建个人信息
//            PersonalInfo personalInfo = new PersonalInfo();
//            personalInfo.setMajor("计算机科学");
//            personalInfo.setAcademicYear("大二");
//            personalInfo.setLearningStyle("实践型");
//            personalInfo.setCareerGoal("成为前端开发工程师");
//            personalInfo.setIntensity("适中");
//            personalInfo.setInterests("Web开发");
//            personalInfo.setSkills(Arrays.asList("HTML", "CSS"));

            CareerPlanRequest request = new CareerPlanRequest();
            request.setSelectedCareer(1);  // 前端开发工程师
            request.setPlanDuration("medium");  // 中期规划
            request.setSkillLevel("intermediate");  // 中级技能水平
            request.setInterests(List.of(1, 3));  // 感兴趣的领域ID
            request.setWeeklyStudyHours("medium");  // 每周学习时间

            // 创建职业规划请求
//            CareerPlanRequest request = new CareerPlanRequest();
//            request.setSelectedCareer(1); // 前端开发工程师
//            request.setPersonalInfo(personalInfo);

            // Mock通义千问API响应异常
            when(restTemplate.postForObject(
                    anyString(),
                    any(HttpEntity.class),
                    ArgumentMatchers.<Class<QianwenAIService.QianwenResponse>>any())
            ).thenThrow(new HttpClientErrorException(HttpStatus.UNAUTHORIZED));


            // 调用方法
            CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);

            // 验证结果
            logger.info("=== 职业规划结果 ===");
            logger.info("目标职业: {}", response.getTargetCareer());
            logger.info("职业路径: {}", response.getCareerPath());
            logger.info("预计时间: {}", response.getEstimatedTime());

            assertNotNull(response, "职业规划响应不应为空");
            assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");
            assertNotNull(response.getSemesters(), "学期规划不应为空");
            assertFalse(response.getSemesters().isEmpty(), "学期规划应包含至少一个学期");

            // 打印详细的学期规划
            response.getSemesters().forEach(semester -> {
                logger.info("学期: {}", semester.getSemester());

                if (semester.getSkills() != null) {
                    semester.getSkills().forEach(skill ->
                            logger.info("技能: {} - 目标: {} - 状态: {}",
                                    skill.getName(), skill.getSemesterGoal(), skill.getStatus())
                    );
                }

                if (semester.getCourses() != null) {
                    semester.getCourses().forEach(course ->
                            logger.info("课程: {} - 学期: {}", course.getName(), course.getSemester())
                    );
                }
            });

        } catch (Exception e) {
            logger.error("生成职业规划时发生异常", e);
            fail("生成职业规划失败: " + e.getMessage());
        }
    }
}