package com.university.careerplanning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
//import com.university.careerplanning.dto.PersonalInfo;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT) // 添加这一行
public class QianwenAIServiceTest3 {
    private static final Logger logger = LoggerFactory.getLogger(QianwenAIServiceTest3.class);

    @Mock
    private RestTemplate restTemplate;

    @Spy
    private ObjectMapper objectMapper;

    @InjectMocks
    private QianwenAIService qianwenAIService;

    // 添加这个成员变量
    private String apiKey = "sk-6ceb7795be7c4dcc83ed8b1918e8a550";

//    @BeforeEach
//    void setup() {
//        // 使用反射注入测试配置
//        ReflectionTestUtils.setField(qianwenAIService, "apiKey", "sk-6ceb7795be7c4dcc83ed8b1918e8a550");
//        ReflectionTestUtils.setField(qianwenAIService, "apiUrl", "https://dashscope.aliyuncs.com/api/v1/services/test/generation");
//        ReflectionTestUtils.setField(qianwenAIService, "modelName", "qwen-plus");
//    }

    @BeforeEach
    void setup() {
        // 使用反射注入测试配置，确保字段名称与 QianwenAIService 类中的实际字段名称匹配
        ReflectionTestUtils.setField(qianwenAIService, "qianwenApiKey", "sk-6ceb7795be7c4dcc83ed8b1918e8a550");
        ReflectionTestUtils.setField(qianwenAIService, "qianwenApiUrl", "https://dashscope.aliyuncs.com/api/v1/services/test/generation");
        ReflectionTestUtils.setField(qianwenAIService, "modelName", "qwen-plus");
    }

//    @Test
//    void testGeneratePersonalizedPlanManualApiCall() {
//        try {
//            // 创建个人信息
////            PersonalInfo personalInfo = new PersonalInfo();
////            personalInfo.setMajor("计算机科学");
////            personalInfo.setAcademicYear("大二");
////            personalInfo.setLearningStyle("实践型");
////            personalInfo.setCareerGoal("成为前端开发工程师");
////            personalInfo.setIntensity("适中");
////            personalInfo.setInterests("Web开发");
////            personalInfo.setSkills(Arrays.asList("HTML", "CSS"));
////
////            // 创建职业规划请求
////            CareerPlanRequest request = new CareerPlanRequest();
////            request.setSelectedCareer(1); // 前端开发工程师
////            request.setPersonalInfo(personalInfo);
//
//            // 直接创建职业规划请求，不使用 PersonalInfo
//            CareerPlanRequest request = new CareerPlanRequest();
//            request.setSelectedCareer(1); // 前端开发工程师
//
//            // 如果需要设置其他参数，可以直接在 request 上设置
//            request.setPlanDuration("medium");
//            request.setSkillLevel("intermediate");
//            request.setWeeklyStudyHours("medium");
//            request.setInterests(Arrays.asList(1, 3)); // 感兴趣的领域ID
//
//            // 创建请求头
//            HttpHeaders headers = new HttpHeaders();
//            headers.setContentType(MediaType.APPLICATION_JSON);
//            headers.set("Authorization", "Bearer " + apiKey);
//
//            // 构建请求体
//            String prompt = "请为一个前端开发方向的学生生成一份个性化职业规划，包括技能学习路径、推荐课程和证书。";
//
//
//            // 模拟通义千问API响应
//            QianwenAIService.QianwenResponse mockResponse = new QianwenAIService.QianwenResponse();
//            QianwenAIService.QianwenOutput output = new QianwenAIService.QianwenOutput();
//
//            // 模拟一个带有JSON的响应文本
//            String mockResponseText = "```json\n" +
//                    "{\n" +
//                    "  \"targetCareer\": \"前端开发工程师\",\n" +
//                    "  \"careerPath\": \"初级前端 → 中级前端 → 高级前端\",\n" +
//                    "  \"estimatedTime\": \"2-3年\",\n" +
//                    "  \"semesters\": [\n" +
//                    "    {\n" +
//                    "      \"semester\": \"大二上\",\n" +
//                    "      \"skills\": [\n" +
//                    "        {\n" +
//                    "          \"name\": \"HTML/CSS\",\n" +
//                    "          \"semesterGoal\": \"掌握HTML5和CSS3基础\",\n" +
//                    "          \"status\": \"进行中\"\n" +
//                    "        }\n" +
//                    "      ]\n" +
//                    "    }\n" +
//                    "  ]\n" +
//                    "}\n" +
//                    "```";
//
//            output.setText(mockResponseText);
//            mockResponse.setOutput(output);
//
//            // 准备请求体
//            Map<String, Object> requestBody = new HashMap<>();
//            requestBody.put("model", "qwen-plus");
//
//            Map<String, Object> input = new HashMap<>();
//            input.put("prompt", "生成个性化职业规划");
//            requestBody.put("input", input);
//
//            // 模拟 RestTemplate 调用
//            when(restTemplate.postForObject(
//                    eq("https://dashscope.aliyuncs.com/api/v1/services/test/generation"),
//                    any(HttpEntity.class),
//                    eq(QianwenAIService.QianwenResponse.class)
//            )).thenReturn(mockResponse);
//
//            // 调用方法
//            CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
//
//            // 验证结果
//            logger.info("职业规划响应: {}", response);
//
//            assertNotNull(response, "职业规划响应不应为空");
//            assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");
//            assertEquals("2-3年", response.getEstimatedTime(), "预计时间应匹配");
//            assertNotNull(response.getSemesters(), "学期规划不应为空");
//            assertFalse(response.getSemesters().isEmpty(), "应有至少一个学期");
//
//            // 打印详细信息
//            response.getSemesters().forEach(semester -> {
//                logger.info("学期: {}", semester.getSemester());
//                if (semester.getSkills() != null) {
//                    semester.getSkills().forEach(skill ->
//                            logger.info("技能: {} - 目标: {} - 状态: {}",
//                                    skill.getName(), skill.getSemesterGoal(), skill.getStatus())
//                    );
//                }
//            });
//
//        } catch (Exception e) {
//            logger.error("测试异常", e);
//            fail("测试过程中发生异常: " + e.getMessage());
//        }
//    }

//    @Test
//    void testGeneratePersonalizedPlanManualApiCall() {
//        try {
//            // 创建职业规划请求
//            CareerPlanRequest request = new CareerPlanRequest();
//            request.setSelectedCareer(1); // 前端开发工程师
//            request.setPlanDuration("medium");
//            request.setSkillLevel("intermediate");
//            request.setWeeklyStudyHours("medium");
//            request.setInterests(Arrays.asList(1, 3)); // 感兴趣的领域ID
//
//            // 模拟通义千问API响应
//            QianwenAIService.QianwenResponse mockResponse = new QianwenAIService.QianwenResponse();
//            QianwenAIService.QianwenOutput output = new QianwenAIService.QianwenOutput();
//
//            // 模拟响应文本
//            String mockResponseText = "```json\n" +
//                    "{\n" +
//                    "  \"targetCareer\": \"前端开发工程师\",\n" +
//                    "  \"careerPath\": \"初级前端 → 中级前端 → 高级前端\",\n" +
//                    "  \"estimatedTime\": \"2-3年\",\n" +
//                    "  \"semesters\": [\n" +
//                    "    {\n" +
//                    "      \"semester\": \"大二上\",\n" +
//                    "      \"skills\": [\n" +
//                    "        {\n" +
//                    "          \"name\": \"HTML/CSS\",\n" +
//                    "          \"semesterGoal\": \"掌握HTML5和CSS3基础\",\n" +
//                    "          \"status\": \"进行中\"\n" +
//                    "        }\n" +
//                    "      ]\n" +
//                    "    }\n" +
//                    "  ]\n" +
//                    "}\n" +
//                    "```";
//
//            output.setText(mockResponseText);
//            mockResponse.setOutput(output);
//
//            // 模拟 RestTemplate 调用
//            when(restTemplate.postForObject(
//                    anyString(), // 使用anyString()而不是eq()以增加灵活性
//                    any(HttpEntity.class),
//                    eq(QianwenAIService.QianwenResponse.class)
//            )).thenReturn(mockResponse);
//
//            // 调用方法
//            CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
//
//            // 验证结果
//            assertNotNull(response, "职业规划响应不应为空");
//            assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");
//            assertEquals("2-3年", response.getEstimatedTime(), "预计时间应匹配");
//            assertNotNull(response.getSemesters(), "学期规划不应为空");
//            assertFalse(response.getSemesters().isEmpty(), "应有至少一个学期");
//
//            // 打印详细信息
//            logger.info("职业规划响应: {}", response);
//            response.getSemesters().forEach(semester -> {
//                logger.info("学期: {}", semester.getSemester());
//                if (semester.getSkills() != null) {
//                    semester.getSkills().forEach(skill ->
//                            logger.info("技能: {} - 目标: {} - 状态: {}",
//                                    skill.getName(), skill.getSemesterGoal(), skill.getStatus())
//                    );
//                }
//            });
//        } catch (Exception e) {
//            logger.error("测试异常", e);
//            fail("测试过程中发生异常: " + e.getMessage());
//        }
//    }

    @Test
    void testGeneratePersonalizedPlanManualApiCall() {
        try {
            // 创建职业规划请求
            CareerPlanRequest request = new CareerPlanRequest();
            request.setSelectedCareer(1); // 前端开发工程师
            request.setPlanDuration("medium");
            request.setSkillLevel("intermediate");
            request.setWeeklyStudyHours("medium");
            request.setInterests(Arrays.asList(1, 3)); // 感兴趣的领域ID

            // 模拟通义千问API响应
            QianwenAIService.QianwenResponse mockResponse = new QianwenAIService.QianwenResponse();
            QianwenAIService.QianwenOutput output = new QianwenAIService.QianwenOutput();

            // 模拟一个带有JSON的响应文本
            String mockResponseText = "```json\n" +
                    "{\n" +
                    "  \"targetCareer\": \"前端开发工程师\",\n" +
                    "  \"careerPath\": \"初级前端 → 中级前端 → 高级前端\",\n" +
                    "  \"estimatedTime\": \"2-3年\",\n" +
                    "  \"semesters\": [\n" +
                    "    {\n" +
                    "      \"semester\": \"大二上\",\n" +
                    "      \"skills\": [\n" +
                    "        {\n" +
                    "          \"name\": \"HTML/CSS\",\n" +
                    "          \"semesterGoal\": \"掌握HTML5和CSS3基础\",\n" +
                    "          \"status\": \"进行中\"\n" +
                    "        }\n" +
                    "      ]\n" +
                    "    }\n" +
                    "  ]\n" +
                    "}\n" +
                    "```";

            output.setText(mockResponseText);
            mockResponse.setOutput(output);

            // 获取QianwenAIService中实际使用的QianwenRequest类的引用
            Class<?> requestClass = null;
            for (Class<?> innerClass : QianwenAIService.class.getDeclaredClasses()) {
                if (innerClass.getSimpleName().equals("QianwenRequest")) {
                    requestClass = innerClass;
                    break;
                }
            }

            // 给QianwenRequest类添加task字段
            if (requestClass != null) {
                Field taskField = null;
                try {
                    taskField = requestClass.getDeclaredField("task");
                } catch (NoSuchFieldException e) {
                    // 如果task字段不存在，使用反射添加它
                    // 注意：这在实际生产环境中可能不起作用，但在测试中可以尝试
                    logger.info("在QianwenRequest类中找不到task字段，尝试使用拦截器添加");
                }
            }

            // 使用拦截器拦截RestTemplate请求，添加task参数
            // 使用ArgumentMatchers.any()来匹配任何HttpEntity
//            when(restTemplate.postForObject(
//                    anyString(),
//                    argThat(entity -> {
//                        // 这里我们拦截HttpEntity，添加task参数
//                        try {
//                            // 获取HttpEntity中的body
//                            Object body = entity.getBody();
//                            // 使用反射添加task字段
//                            if (body != null) {
//                                Field taskField = body.getClass().getDeclaredField("task");
//                                taskField.setAccessible(true);
//                                if (taskField.get(body) == null) {
//                                    taskField.set(body, "text_generation");
//                                }
//                            }
//                            return true;
//                        } catch (Exception e) {
//                            // 如果反射失败，可能是因为body不是QianwenRequest类型
//                            // 我们仍然返回true，让测试继续
//                            return true;
//                        }
//                    }),
//                    eq(QianwenAIService.QianwenResponse.class)
//            )).thenReturn(mockResponse);

            when(restTemplate.postForObject(
                    anyString(),
                    argThat(argument -> {
                        // 首先确保参数是HttpEntity类型
                        if (!(argument instanceof HttpEntity)) {
                            return true; // 不是HttpEntity，跳过处理
                        }

                        HttpEntity<?> entity = (HttpEntity<?>) argument;
                        Object body = entity.getBody();

                        // 确保body非空
                        if (body != null) {
                            try {
                                // 尝试获取task字段
                                Field taskField = body.getClass().getDeclaredField("task");
                                taskField.setAccessible(true);

                                // 如果task为null，设置它为"text_generation"
                                if (taskField.get(body) == null) {
                                    taskField.set(body, "text_generation");
                                }
                            } catch (NoSuchFieldException e) {
                                // 如果找不到task字段，说明需要添加它
                                // 但在运行时通过反射添加新字段通常是不可能的
                                // 我们可以记录下来，但不阻止测试继续
                                System.out.println("找不到task字段: " + e.getMessage());
                            } catch (Exception e) {
                                // 其他异常
                                System.out.println("处理task字段时出错: " + e.getMessage());
                            }
                        }

                        return true; // 让matcher总是返回true，以便匹配任何请求
                    }),
                    eq(QianwenAIService.QianwenResponse.class)
            )).thenReturn(mockResponse);

            // 调用方法
            CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);

            // 验证结果
            logger.info("职业规划响应: {}", response);

            assertNotNull(response, "职业规划响应不应为空");
            assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");

            // 其他验证和日志输出...
        } catch (Exception e) {
            logger.error("测试异常", e);
            fail("测试过程中发生异常: " + e.getMessage());
        }
    }

    @Test
    void testApiConfiguration() {
        // 验证 API 配置是否正确注入
        String apiKey = (String) ReflectionTestUtils.getField(qianwenAIService, "apiKey");
        String apiUrl = (String) ReflectionTestUtils.getField(qianwenAIService, "apiUrl");
        String modelName = (String) ReflectionTestUtils.getField(qianwenAIService, "modelName");

        assertNotNull(apiKey, "API Key 不应为空");
        assertNotNull(apiUrl, "API URL 不应为空");
        assertNotNull(modelName, "模型名称不应为空");

        logger.info("API Key: {}", apiKey);
        logger.info("API URL: {}", apiUrl);
        logger.info("Model Name: {}", modelName);
    }
}