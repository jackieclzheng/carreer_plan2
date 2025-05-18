package com.university.careerplanning.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.*;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

// Apache HttpClient 相关包
//import org.apache.http.HttpResponse;
//import org.apache.http.client.methods.HttpPost;
//import org.apache.http.entity.ContentType;
//import org.apache.http.entity.StringEntity;
//import org.apache.http.impl.client.CloseableHttpClient;
//import org.apache.http.impl.client.HttpClients;
//import org.apache.http.util.EntityUtils;

// 其他必要的包
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class QianwenAIService {
    private static final Logger logger = LoggerFactory.getLogger(QianwenAIService.class);

    @Value("${qianwen.api.url:https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation}")
    private String qianwenApiUrl;

    @Value("${qianwen.api.key}")
    private String qianwenApiKey;

    @Value("${qianwen.model.name:qwen-plus}")
    private String modelName;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 缓存用户的职业规划数据，生产环境应使用数据库
    private final Map<String, CareerPlanResponse> userPlans = new HashMap<>();

    // 缓存API调用结果
    private final Map<String, CareerPlanResponse> responseCache = new HashMap<>();

    // 预定义的职业方向列表
    private static final List<Map<String, Object>> CAREER_DIRECTIONS = List.of(
            Map.of("id", 1, "title", "前端开发工程师", "description", "专注于Web前端开发技术"),
            Map.of("id", 2, "title", "后端开发工程师", "description", "Java企业级应用开发"),
            Map.of("id", 3, "title", "Python开发工程师", "description", "Python应用开发和数据分析"),
            Map.of("id", 4, "title", "全栈开发工程师", "description", "前后端全栈开发技术"),
            Map.of("id", 5, "title", "数据工程师", "description", "大数据处理和分析"),
            Map.of("id", 6, "title", "DevOps工程师", "description", "开发运维一体化")
    );

    /**
     * 获取职业方向列表
     * @return 职业方向列表
     */
//    public List<CareerDirectionDTO> getCareerDirections() {
//        return CAREER_DIRECTIONS.stream()
//                .map(map -> {
//                    CareerDirectionDTO dto = new CareerDirectionDTO();
//                    dto.setId((Integer) map.get("id"));
//                    dto.setTitle((String) map.get("title"));
//                    dto.setDescription((String) map.get("description"));
//                    return dto;
//                })
//                .collect(Collectors.toList());
//    }

    public List<CareerDirectionDTO> getCareerDirections() {

        // 记录API调用详情
        logger.info("开始调用通义千问API");
//        logger.info("使用的API Key: {}", apiKey); // 打印当前使用的API Key

        return CAREER_DIRECTIONS.stream()
                .map(map -> {
                    CareerDirectionDTO dto = new CareerDirectionDTO();
                    dto.setId((Integer) map.get("id"));
                    dto.setTitle((String) map.get("title"));

                    // 不再设置description字段
                    // 如果需要，可以创建和设置其他字段
                    List<SkillSemesterGoalDTO> skills = new ArrayList<>();
                    List<SemesterCourseDTO> courses = new ArrayList<>();
                    List<SemesterCertificateDTO> certificates = new ArrayList<>();

                    // 根据职业ID设置不同的推荐技能、课程和证书
                    if ((Integer)map.get("id") == 1) { // 前端开发
                        skills.add(createSkillDTO("HTML/CSS", "掌握HTML5和CSS3基础"));
                        skills.add(createSkillDTO("JavaScript", "掌握JavaScript和DOM编程"));
                        courses.add(createCourseDTO("Web前端开发基础", "大二上"));
                        certificates.add(createCertificateDTO("前端开发工程师认证", "大三上"));
                    } else if ((Integer)map.get("id") == 2) { // 后端开发
                        skills.add(createSkillDTO("Java基础", "掌握Java核心语法"));
                        skills.add(createSkillDTO("Spring框架", "学习Spring Boot开发"));
                        courses.add(createCourseDTO("Java程序设计", "大二上"));
                        certificates.add(createCertificateDTO("Java工程师认证", "大三上"));
                    } else { // 其他职业
                        skills.add(createSkillDTO("编程基础", "掌握编程基本概念"));
                        courses.add(createCourseDTO("程序设计基础", "大二上"));
                        certificates.add(createCertificateDTO("软件开发工程师认证", "大三上"));
                    }

                    dto.setRecommendedSkills(skills);
                    dto.setRecommendedCourses(courses);
                    dto.setRecommendedCertificates(certificates);

                    return dto;
                })
                .collect(Collectors.toList());
    }

    // 辅助方法创建技能DTO
    private SkillSemesterGoalDTO createSkillDTO(String name, String goal) {
        SkillSemesterGoalDTO skill = new SkillSemesterGoalDTO();
        skill.setName(name);
        skill.setSemesterGoal(goal);
        return skill;
    }

    // 辅助方法创建课程DTO
    private SemesterCourseDTO createCourseDTO(String name, String semester) {
        SemesterCourseDTO course = new SemesterCourseDTO();
        course.setName(name);
        course.setSemester(semester);
        return course;
    }

    // 辅助方法创建证书DTO
    private SemesterCertificateDTO createCertificateDTO(String name, String semester) {
        SemesterCertificateDTO cert = new SemesterCertificateDTO();
        cert.setName(name);
        cert.setSemester(semester);
        return cert;
    }

    /**
     * 生成个性化职业规划
     * @param request 职业规划请求
     * @return 职业规划响应
     */
    public CareerPlanResponse generatePersonalizedPlan(CareerPlanRequest request) {
        try {
            // 生成缓存键
            String cacheKey = generateCacheKey(request);

            // 检查缓存
            if (responseCache.containsKey(cacheKey)) {
                logger.info("使用缓存的职业规划: {}", cacheKey);
                return responseCache.get(cacheKey);
            }

            // 构建请求通义千问API的参数
//            QianwenRequest qianwenRequest = new QianwenRequest();
//            qianwenRequest.setModel(modelName);


            // 构建提示词
//            String prompt = buildPrompt(request);
//            qianwenRequest.setInput(new QianwenInput(prompt));

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", modelName);
            requestBody.put("input", Map.of("prompt", buildPrompt(request)));
            requestBody.put("task", "text_generation");  // 确保这个字段存在
            requestBody.put("parameters", Map.of(
                    "temperature", 0.4,
                    "max_tokens", 2000,
                    "top_p", 0.8
            ));

            // 配置通义千问API请求头
//            HttpHeaders headers = new HttpHeaders();
//            headers.setContentType(MediaType.APPLICATION_JSON);
//            headers.set("Authorization", "Bearer " + qianwenApiKey);
//
//            logger.info("发送请求到通义千问API");
//            // 发送请求到通义千问API
////            HttpEntity<QianwenRequest> requestEntity = new HttpEntity<>(qianwenRequest, headers);
//            // 发送请求到通义千问API
//            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
//            // 使用正确结构的requestBody创建HttpEntity
////            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
//
//            logger.info("发送请求到通义千问API，requestEntity请求体: {}", objectMapper.writeValueAsString(requestEntity));
//            logger.info("发送请求到通义千问API，requestBody请求体: {}", objectMapper.writeValueAsString(requestBody));
//
////            try {
////                String requestJson = objectMapper.writeValueAsString(qianwenRequest);
////                logger.info("发送请求到通义千问API，请求体: {}", requestJson);
////            } catch (Exception e) {
////                logger.error("序列化请求体失败", e);
////            }
//
//            QianwenResponse qianwenResponse = restTemplate.postForObject(
//                    qianwenApiUrl,
//                    requestEntity,
////                    requestBody,
//                    QianwenResponse.class
//            );


            // 使用HttpClient直接发送请求
//            CloseableHttpClient httpClient = HttpClients.createDefault();
//            HttpPost httpPost = new HttpPost(qianwenApiUrl);
//
//            // 设置请求头
//            httpPost.setHeader("Content-Type", "application/json");
//            httpPost.setHeader("Authorization", "Bearer " + qianwenApiKey);
//
//
//            // 序列化请求体为JSON字符串
//            String json = objectMapper.writeValueAsString(requestBody);
//            logger.info("使用HttpClient发送请求，请求体: {}", json);
//
//            // 设置请求体
//            StringEntity entity = new StringEntity(json, ContentType.APPLICATION_JSON);
//            httpPost.setEntity(entity);
//
//            // 执行请求
//            HttpResponse response = httpClient.execute(httpPost);
//            int statusCode = response.getStatusLine().getStatusCode();
//            String responseBody = EntityUtils.toString(response.getEntity());
//
//            logger.info("API响应状态码: {}", statusCode);
//            logger.info("API响应内容: {}", responseBody);
//
//            // 解析响应
//            if (statusCode == 200) {
//                return objectMapper.readValue(responseBody, QianwenResponse.class);
//            } else {
//                logger.error("API错误: {}", responseBody);
//                throw new RuntimeException("API调用失败: " + responseBody);
//            }


//            import java.net.URI;
//import java.net.http.HttpClient;
//import java.net.http.HttpRequest;
//import java.net.http.HttpResponse;
//import java.time.Duration;

            // 创建HttpClient
            HttpClient httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();

            // 在try块内，现有代码前添加这段
//            String hardcodedJson = "{\n" +
//                    "    \"model\": \"qwen-plus\",\n" +
//                    "    \"input\": {\n" +
//                    "        \"prompt\": \"简单测试\"\n" +
//                    "    },\n" +
//                    "    \"task\": \"text_generation\",\n" +
//                    "    \"parameters\": {\n" +
//                    "        \"temperature\": 0.4,\n" +
//                    "        \"max_tokens\": 100,\n" +
//                    "        \"top_p\": 0.8\n" +
//                    "    }\n" +
//                    "}";
//
//            logger.info("使用硬编码JSON测试API: {}", hardcodedJson);

            String qianwenApiUrl = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

            // 创建请求
            HttpRequest requestNative = HttpRequest.newBuilder()
                    .uri(URI.create(qianwenApiUrl))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + qianwenApiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(requestBody)))
                    .build();

            // 或者如果您在代码中直接设置这个URL，请修改为
//            String qianwenApiUrl = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

            // 创建请求
//            HttpRequest hardcodedRequest = HttpRequest.newBuilder()
//                    .uri(URI.create(qianwenApiUrl))
//                    .header("Content-Type", "application/json")
//                    .header("Authorization", "Bearer " + qianwenApiKey)
//                    .POST(HttpRequest.BodyPublishers.ofString(hardcodedJson))
//                    .build();

            // 发送请求并获取响应
            HttpResponse<String> response = httpClient.send(requestNative, HttpResponse.BodyHandlers.ofString());
            int statusCode = response.statusCode();
            String responseBody = response.body();

            logger.info("API响应状态码: {}", statusCode);
            logger.info("API响应内容: {}", responseBody);

            // 发送请求并获取响应
//            HttpResponse<String> hardcodedResponse = httpClient.send(hardcodedRequest, HttpResponse.BodyHandlers.ofString());
//            int hardcodedStatusCode = hardcodedResponse.statusCode();
//            String hardcodedResponseBody = hardcodedResponse.body();
//
//            logger.info("硬编码请求API响应状态码: {}", hardcodedStatusCode);
//            logger.info("硬编码请求API响应内容: {}", hardcodedResponseBody);

            // 如果硬编码测试成功，则证明问题在您的JSON生成中
//            if (hardcodedStatusCode == 200) {
//                logger.info("硬编码请求成功，问题在于您的请求体构造");
//            }


            // 解析响应
//            QianwenResponse qianwenResponse;
//            if (statusCode == 200) {
////                return objectMapper.readValue(responseBody, QianwenResponse.class);
//                qianwenResponse = objectMapper.readValue(responseBody, QianwenResponse.class);
//                // 从QianwenResponse中提取文本内容
//                String generatedText = qianwenResponse.getOutput().getText();
//
//                // 解析生成的文本为CareerPlanResponse
//                return parseGeneratedPlan(generatedText, request);
//            } else {
//                logger.error("API错误: {}", responseBody);
//                throw new RuntimeException("API调用失败: " + responseBody);
//            }
//
//            // 解析通义千问的响应获取生成的职业规划
////            QianwenResponse qianwenResponse = new QianwenResponse();
//            if (qianwenResponse != null && qianwenResponse.getOutput() != null) {
//                String generatedPlan = qianwenResponse.getOutput().getText();
//                logger.info("成功获取通义千问响应，正在解析");
//
//                // 尝试将文本解析为JSON并转换为CareerPlanResponse对象
//                CareerPlanResponse plan = parseGeneratedPlan(generatedPlan, request);
//
//                // 保存用户的规划以便后续更新
//                String userId = "user-" + System.currentTimeMillis(); // 这里应该使用实际的用户ID
//                userPlans.put(userId, plan);
//
//                // 存入缓存
//                responseCache.put(cacheKey, plan);
//
//                return plan;
//            } else {
//                logger.warn("通义千问响应为空或无效");
//                // 返回备用规划数据
//                CareerPlanResponse fallbackPlan = generateFallbackPlan(request);
//                responseCache.put(cacheKey, fallbackPlan);
//                return fallbackPlan;
//            }

            QianwenResponse qianwenResponse = null;

            if (statusCode == 200) {
                try {
                    // 解析响应JSON
                    qianwenResponse = objectMapper.readValue(responseBody, QianwenResponse.class);

                    // 检查响应是否有效
                    if (qianwenResponse != null && qianwenResponse.getOutput() != null) {
                        // 从QianwenResponse中提取文本内容
                        String generatedText = qianwenResponse.getOutput().getText();
                        logger.info("成功获取通义千问响应，正在解析");

                        // 解析生成的文本为CareerPlanResponse对象
                        CareerPlanResponse plan = parseGeneratedPlan(generatedText, request);

                        // 保存用户的规划以便后续更新
                        String userId = "user-" + System.currentTimeMillis(); // 这里应该使用实际的用户ID
                        userPlans.put(userId, plan);

                        // 存入缓存
                        String cacheKeyNative = generateCacheKey(request);
                        responseCache.put(cacheKeyNative, plan);

                        return plan;
                    } else {
                        logger.warn("通义千问响应为空或无效");
                        // 返回备用规划数据
                        return generateFallbackPlan(request);
                    }
                } catch (Exception e) {
                    logger.error("解析通义千问响应失败", e);
                    // 返回备用规划数据
                    return generateFallbackPlan(request);
                }
            } else {
                logger.error("API错误: {}", responseBody);
                // 在出错时也返回备用计划，而不是抛出异常
                // throw new RuntimeException("API调用失败: " + responseBody);
                return generateFallbackPlan(request);
            }

//            QianwenResponse qianwenResponse = null;
////
//            if (hardcodedStatusCode == 200) {
//                try {
//                    // 解析响应JSON
////                    qianwenResponse = objectMapper.readValue(hardcodedResponse, QianwenResponse.class);
//                    qianwenResponse = objectMapper.readValue(hardcodedResponseBody, QianwenResponse.class);
//
//                    // 检查响应是否有效
//                    if (qianwenResponse != null && qianwenResponse.getOutput() != null) {
//                        // 从QianwenResponse中提取文本内容
//                        String generatedText = qianwenResponse.getOutput().getText();
//                        logger.info("成功获取通义千问响应，正在解析");
//
//                        // 解析生成的文本为CareerPlanResponse对象
//                        CareerPlanResponse plan = parseGeneratedPlan(generatedText, request);
//
//                        // 保存用户的规划以便后续更新
//                        String userId = "user-" + System.currentTimeMillis(); // 这里应该使用实际的用户ID
//                        userPlans.put(userId, plan);
//
//                        // 存入缓存
//                        String cacheKeyNative = generateCacheKey(request);
//                        responseCache.put(cacheKeyNative, plan);
//
//                        return plan;
//                    } else {
//                        logger.warn("通义千问响应为空或无效");
//                        // 返回备用规划数据
//                        return generateFallbackPlan(request);
//                    }
//                } catch (Exception e) {
//                    logger.error("解析通义千问响应失败", e);
//                    // 返回备用规划数据
//                    return generateFallbackPlan(request);
//                }
//            } else {
//                logger.error("API错误: {}", hardcodedResponse);
//                // 在出错时也返回备用计划，而不是抛出异常
//                // throw new RuntimeException("API调用失败: " + responseBody);
//                return generateFallbackPlan(request);
//            }
        } catch (Exception e) {
            logger.error("调用通义千问API失败", e);
            // 返回备用规划数据
            return generateFallbackPlan(request);
        }
    }

    /**
     * 更新技能状态
     * @param request 技能更新请求
     */
    public void updateSkillStatus(SkillUpdateRequest request) {
        // 在实际应用中，这里应该更新数据库中的技能状态
        logger.info("更新技能状态: 学期索引={}, 技能索引={}, 新状态={}",
                request.getSemesterIndex(), request.getSkillIndex(), request.getNewStatus());

        // 查找最近生成的一个计划并更新 (简化，实际应基于用户ID)
        if (!userPlans.isEmpty()) {
            CareerPlanResponse plan = userPlans.values().iterator().next();
            if (plan.getSemesters().size() > request.getSemesterIndex()) {
                CareerPlanResponse.Semester semester = plan.getSemesters().get(request.getSemesterIndex());
                if (semester.getSkills().size() > request.getSkillIndex()) {
                    semester.getSkills().get(request.getSkillIndex()).setStatus(request.getNewStatus());
                    logger.info("成功更新技能状态");
                }
            }
        }
    }

    /**
     * 构建提示词，包含所有个性化信息
     */
    private String buildPrompt(CareerPlanRequest request) {
        // 根据用户选择的职业方向ID获取职业名称
        String careerTitle = CAREER_DIRECTIONS.stream()
                .filter(career -> career.get("id").equals(request.getSelectedCareer()))
                .map(career -> career.get("title").toString())
                .findFirst()
                .orElse("软件工程师");

        // 构建提示词
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位职业规划和技术发展专家。请根据以下信息，为用户生成一份详细的个性化职业规划，格式为JSON：\n\n");
        prompt.append("目标职业：").append(careerTitle).append("\n");

        // 处理新版本字段
        if (request.getPersonalInfo() != null) {
            prompt.append("===用户个性化信息===\n");
            prompt.append("专业背景：").append(request.getPersonalInfo().getMajor()).append("\n");
            prompt.append("当前学年：").append(request.getPersonalInfo().getAcademicYear()).append("\n");

            // 处理已掌握技能
            prompt.append("已掌握技能：");
            if (request.getPersonalInfo().getSkills() != null && !request.getPersonalInfo().getSkills().isEmpty()) {
                prompt.append(String.join(", ", request.getPersonalInfo().getSkills()));
            } else {
                prompt.append("无");
            }
            prompt.append("\n");

            prompt.append("学习风格偏好：").append(request.getPersonalInfo().getLearningStyle()).append("\n");
            prompt.append("职业发展目标：").append(request.getPersonalInfo().getCareerGoal()).append("\n");
            prompt.append("学习强度：").append(request.getPersonalInfo().getIntensity()).append("\n");
            prompt.append("兴趣领域：").append(request.getPersonalInfo().getInterests()).append("\n\n");
        } else {
            // 处理旧版本字段
            prompt.append("规划时长：").append(request.getPlanDuration()).append("（short=短期1年，medium=中期2-3年，long=长期4-5年）\n");
            prompt.append("当前技能水平：").append(request.getSkillLevel()).append("（beginner=初学者，intermediate=中级，advanced=高级）\n");
            prompt.append("兴趣领域ID：").append(request.getInterests()).append("\n");
            prompt.append("每周学习时间：").append(request.getWeeklyStudyHours()).append("（low=5-10小时/周，medium=10-20小时/周，high=20+小时/周）\n\n");
        }

        prompt.append("生成的JSON职业规划应包含以下字段：\n");
        prompt.append("1. targetCareer: 目标职业名称\n");
        prompt.append("2. careerGoal: 职业目标\n");
        prompt.append("3. majorBackground: 专业背景\n");
        prompt.append("4. learningStyle: 学习风格\n");
        prompt.append("5. intensity: 学习强度\n");
        prompt.append("6. interests: 兴趣领域\n");
        prompt.append("7. careerPath: 职业发展路径\n");
        prompt.append("8. estimatedTime: 预计达成时间\n");
        prompt.append("9. corePower: 核心竞争力\n");
        prompt.append("10. semesters: 学期规划列表，每学期包含：\n");
        prompt.append("   - semester: 学期名称（例如'大二上'，从用户当前学年开始）\n");
        prompt.append("   - skills: 技能列表（排除用户已掌握的技能），每个技能包含：\n");
        prompt.append("     * name: 技能名称\n");
        prompt.append("     * semesterGoal: 学习目标（根据用户学习风格定制）\n");
        prompt.append("     * status: 状态（第一学期第一个技能为'进行中'，其他为'未开始'）\n");
        prompt.append("   - courses: 课程列表，每个课程包含name, semester\n");
        prompt.append("   - certificates: 证书列表，每个证书包含name, semester\n\n");

        prompt.append("根据用户的学习强度，每学期安排的技能数量应相应调整：\n");
        prompt.append("- 轻松：每学期1个技能\n");
        prompt.append("- 适中：每学期2个技能\n");
        prompt.append("- 强化：每学期3个技能\n");
        prompt.append("- 密集：每学期4个技能\n\n");

        prompt.append("根据用户的学习风格，调整学习目标的描述方式：\n");
        prompt.append("- 视觉型：通过视频教程和图表学习\n");
        prompt.append("- 听觉型：通过讲座和音频资料学习\n");
        prompt.append("- 实践型：通过实践项目和练习学习\n");
        prompt.append("- 阅读型：通过阅读书籍和文档学习\n\n");

        prompt.append("参考输出格式：\n");
        prompt.append("{\n");
        prompt.append("  \"targetCareer\": \"前端开发工程师\",\n");
        prompt.append("  \"careerGoal\": \"成为高级前端开发工程师\",\n");
        prompt.append("  \"majorBackground\": \"计算机科学\",\n");
        prompt.append("  \"learningStyle\": \"实践型\",\n");
        prompt.append("  \"intensity\": \"适中\",\n");
        prompt.append("  \"interests\": \"网页设计, 用户体验\",\n");
        prompt.append("  \"careerPath\": \"初级前端 → 中级前端 → 高级前端 → 技术专家\",\n");
        prompt.append("  \"estimatedTime\": \"3年\",\n");
        prompt.append("  \"corePower\": \"UI/UX设计能力、前端框架精通\",\n");
        prompt.append("  \"semesters\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"semester\": \"大二上\",\n");
        prompt.append("      \"skills\": [\n");
        prompt.append("        {\n");
        prompt.append("          \"name\": \"HTML/CSS\",\n");
        prompt.append("          \"semesterGoal\": \"掌握HTML5和CSS3基础，通过实践项目和练习学习\",\n");
        prompt.append("          \"status\": \"进行中\"\n");
        prompt.append("        }\n");
        prompt.append("      ],\n");
        prompt.append("      \"courses\": [\n");
        prompt.append("        {\n");
        prompt.append("          \"name\": \"Web前端开发基础\",\n");
        prompt.append("          \"semester\": \"大二上\"\n");
        prompt.append("        }\n");
        prompt.append("      ],\n");
        prompt.append("      \"certificates\": []\n");
        prompt.append("    }\n");
        prompt.append("  ]\n");
        prompt.append("}\n\n");

        prompt.append("请确保生成的JSON有效，整洁，没有语法错误，并且根据用户的专业背景、已有技能、学习风格和职业目标来定制规划内容。");

        return prompt.toString();
    }

    /**
     * 解析生成的计划文本为结构化对象
     */
    private CareerPlanResponse parseGeneratedPlan(String generatedText, CareerPlanRequest request) {
        try {
            // 从生成的文本中提取JSON部分
            String jsonPart = extractJsonFromText(generatedText);
            logger.info("提取到JSON部分，长度为{}", jsonPart.length());

            // 解析JSON为CareerPlanResponse对象
            CareerPlanResponse response = objectMapper.readValue(jsonPart, CareerPlanResponse.class);

            // 确保旧版本字段与新版本字段同步
            if (response.getIntensity() != null && response.getLearningIntensity() == null) {
                response.setLearningIntensity(response.getIntensity());
            }

            // 确保技能状态字段存在
            ensureSkillsHaveStatus(response);

            return response;
        } catch (Exception e) {
            logger.error("解析生成的JSON失败，尝试修复", e);

            // 尝试修复JSON格式问题
            try {
                String fixedJson = fixJsonFormat(generatedText);
                logger.info("使用修复后的JSON尝试解析");
                return objectMapper.readValue(fixedJson, CareerPlanResponse.class);
            } catch (Exception e2) {
                logger.error("修复JSON并解析失败，使用备用计划", e2);
                // 修复失败，返回备用计划
                return generateFallbackPlan(request);
            }
        }
    }

    /**
     * 从文本中提取JSON部分
     */
    private String extractJsonFromText(String text) {
        // 尝试从文本中提取JSON部分，通常AI会生成一段解释再给出JSON
        int startIndex = text.indexOf("{");
        int endIndex = text.lastIndexOf("}") + 1;

        if (startIndex != -1 && endIndex > startIndex) {
            return text.substring(startIndex, endIndex);
        }

        // 如果找不到明确的JSON格式，返回整个文本
        return text;
    }

    /**
     * 尝试修复常见的JSON格式问题
     */
    private String fixJsonFormat(String text) {
        // 提取JSON部分
        int startIndex = text.indexOf("{");
        int endIndex = text.lastIndexOf("}") + 1;

        if (startIndex == -1 || endIndex <= startIndex) {
            logger.warn("找不到有效的JSON结构，无法修复");
            throw new IllegalArgumentException("无法从文本中提取JSON结构");
        }

        String jsonText = text.substring(startIndex, endIndex);

        // 修复常见的JSON格式问题
        // 1. 修复未加引号的键名
        jsonText = jsonText.replaceAll("(\\s*)(\\w+)(\\s*):", "$1\"$2\"$3:");

        // 2. 修复末尾多余的逗号
        jsonText = jsonText.replaceAll(",\\s*}", "}");
        jsonText = jsonText.replaceAll(",\\s*]", "]");

        // 3. 修复缺少逗号的情况
        jsonText = jsonText.replaceAll("\"\\s*\"", "\",\"");

        // 4. 修复不正确的布尔值
        jsonText = jsonText.replaceAll(":\\s*True\\s*([,}])", ": true$1");
        jsonText = jsonText.replaceAll(":\\s*False\\s*([,}])", ": false$1");

        return jsonText;
    }

    /**
     * 确保所有技能都有状态字段
     */
    private void ensureSkillsHaveStatus(CareerPlanResponse response) {
        if (response == null || response.getSemesters() == null) {
            return;
        }

        for (int i = 0; i < response.getSemesters().size(); i++) {
            CareerPlanResponse.Semester semester = response.getSemesters().get(i);
            if (semester.getSkills() == null) {
                continue;
            }

            for (int j = 0; j < semester.getSkills().size(); j++) {
                CareerPlanResponse.Skill skill = semester.getSkills().get(j);
                // 第一个学期的第一个技能设为"进行中"，其他为"未开始"
                if (skill.getStatus() == null) {
                    if (i == 0 && j == 0) {
                        skill.setStatus("进行中");
                    } else {
                        skill.setStatus("未开始");
                    }
                }
            }
        }
    }

    /**
     * 生成缓存键
     */
    private String generateCacheKey(CareerPlanRequest request) {
        StringBuilder key = new StringBuilder();
        key.append("career_").append(request.getSelectedCareer());

        if (request.getPersonalInfo() != null) {
            key.append("_major_").append(request.getPersonalInfo().getMajor());
            key.append("_year_").append(request.getPersonalInfo().getAcademicYear());
            key.append("_style_").append(request.getPersonalInfo().getLearningStyle());
            key.append("_goal_").append(request.getPersonalInfo().getCareerGoal());
            key.append("_intensity_").append(request.getPersonalInfo().getIntensity());
        } else {
            key.append("_duration_").append(request.getPlanDuration());
            key.append("_skill_").append(request.getSkillLevel());
            key.append("_hours_").append(request.getWeeklyStudyHours());
        }

        return key.toString();
    }

    /**
     * 生成备用的职业规划，当API调用失败时使用
     */
    private CareerPlanResponse generateFallbackPlan(CareerPlanRequest request) {
        logger.info("生成备用职业规划");

        // 获取职业名称
        String careerTitle = CAREER_DIRECTIONS.stream()
                .filter(career -> career.get("id").equals(request.getSelectedCareer()))
                .map(career -> career.get("title").toString())
                .findFirst()
                .orElse("软件工程师");

        // 创建备用规划
        CareerPlanResponse response = new CareerPlanResponse();
        response.setTargetCareer(careerTitle);

        // 设置新字段
        if (request.getPersonalInfo() != null) {
            // 个人背景信息
            response.setMajorBackground(request.getPersonalInfo().getMajor());
            response.setLearningStyle(request.getPersonalInfo().getLearningStyle());
            response.setIntensity(request.getPersonalInfo().getIntensity());
            response.setInterests(request.getPersonalInfo().getInterests());
            response.setCareerGoal(request.getPersonalInfo().getCareerGoal());

            // 旧版本字段兼容
            response.setLearningIntensity(request.getPersonalInfo().getIntensity());
            response.setSkillLevel("中级");

            // 职业路径信息
            response.setCareerPath("初级" + careerTitle + " → 中级" + careerTitle + " → 高级" + careerTitle + " → 技术专家/架构师");
            response.setEstimatedTime(response.getIntensity().equals("密集") ? "2年" : "3-4年");
            response.setCorePower(getCorePower(careerTitle));

            // 学习强度和规划开始学期
            String intensity = request.getPersonalInfo().getIntensity();
            String startSemester = determineStartSemester(request.getPersonalInfo().getAcademicYear());
            List<String> knownSkills = request.getPersonalInfo().getSkills();

            // 根据用户信息创建学期规划
            List<CareerPlanResponse.Semester> semesters;
            if (request.getSelectedCareer() == 1) { // 前端
                semesters = createFrontendPlan(startSemester, intensity, knownSkills,
                        request.getPersonalInfo().getLearningStyle());
            } else if (request.getSelectedCareer() == 2) { // 后端
                semesters = createBackendPlan(startSemester, intensity, knownSkills,
                        request.getPersonalInfo().getLearningStyle());
            } else if (request.getSelectedCareer() == 3) { // Python
                semesters = createPythonPlan(startSemester, intensity, knownSkills,
                        request.getPersonalInfo().getLearningStyle());
            } else {
                semesters = createGenericPlan(startSemester, intensity, knownSkills,
                        request.getPersonalInfo().getLearningStyle());
            }

            response.setSemesters(semesters);
        } else {
            // 兼容旧版本字段
            String difficultyLevel = "beginner".equals(request.getSkillLevel()) ? "基础" :
                    "intermediate".equals(request.getSkillLevel()) ? "进阶" : "高级";
            String planYears = "short".equals(request.getPlanDuration()) ? "1" :
                    "medium".equals(request.getPlanDuration()) ? "2-3" : "4-5";
            String contentDensity = "low".equals(request.getWeeklyStudyHours()) ? "基础" :
                    "medium".equals(request.getWeeklyStudyHours()) ? "标准" : "密集";

            response.setCareerPath("初级" + careerTitle + " → 中级" + careerTitle + " → 高级" + careerTitle + " → 技术专家/架构师");
            response.setEstimatedTime(planYears + "年");
            response.setCorePower(getCorePower(careerTitle));
            response.setLearningIntensity(contentDensity);
            response.setSkillLevel(difficultyLevel);

            // 使用旧方法创建学期规划
            List<CareerPlanResponse.Semester> semesters;
            if (request.getSelectedCareer() == 1) {
                semesters = createFrontendPlan(difficultyLevel, request.getWeeklyStudyHours());
            } else if (request.getSelectedCareer() == 2) {
                semesters = createBackendPlan(difficultyLevel, request.getWeeklyStudyHours());
            } else {
                semesters = createGenericPlan(difficultyLevel, request.getWeeklyStudyHours());
            }

            response.setSemesters(semesters);
        }

        return response;
    }

    /**
     * 根据学年确定起始学期
     */
    private String determineStartSemester(String academicYear) {
        if (academicYear == null || academicYear.isEmpty()) {
            return "大二上"; // 默认
        }

        switch (academicYear) {
            case "大一":
                return "大一下";
            case "大二":
                return "大二上";
            case "大三":
                return "大三上";
            case "大四":
                return "大四上";
            default:
                return "大二上"; // 默认
        }
    }

    /**
     * 获取职业核心竞争力
     */
    private String getCorePower(String careerTitle) {
        if (careerTitle.contains("前端")) {
            return "UI/UX设计能力、交互设计能力、前端框架精通";
        } else if (careerTitle.contains("后端")) {
            return "系统架构设计、数据库优化、高并发处理";
        } else if (careerTitle.contains("Python")) {
            return "数据分析能力、脚本开发、机器学习基础";
        } else if (careerTitle.contains("全栈")) {
            return "全栈技术、项目管理、问题解决能力";
        } else if (careerTitle.contains("数据")) {
            return "大数据处理技术、数据挖掘、数据可视化";
        } else if (careerTitle.contains("DevOps")) {
            return "自动化部署、CI/CD、容器技术";
        } else {
            return "全栈技术、项目管理、问题解决能力";
        }
    }

    // 创建前端开发职业计划 - 旧版本
    private List<CareerPlanResponse.Semester> createFrontendPlan(String difficultyLevel, String weeklyStudyHours) {
        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 第一学期
        CareerPlanResponse.Semester semester1 = new CareerPlanResponse.Semester();
        semester1.setSemester("大二上");

        // 技能
        CareerPlanResponse.Skill skill1 = new CareerPlanResponse.Skill();
        skill1.setName("HTML/CSS");
        skill1.setSemesterGoal("掌握" + difficultyLevel + "HTML5和CSS3技术");
        skill1.setStatus("进行中");
        skill1.setLearningResources("推荐课程：《现代HTML与CSS实战》、MDN Web文档");

        // 课程
        CareerPlanResponse.Course course1 = new CareerPlanResponse.Course();
        course1.setName("Web前端开发基础");
        course1.setSemester("大二上");
        course1.setDifficulty("beginner".equals(weeklyStudyHours) ? 2 : "medium".equals(weeklyStudyHours) ? 3 : 4);
        course1.setEstimatedHours("low".equals(weeklyStudyHours) ? "30" : "medium".equals(weeklyStudyHours) ? "45" : "60");

        semester1.setSkills(List.of(skill1));
        semester1.setCourses(List.of(course1));
        semester1.setCertificates(new ArrayList<>());

        // 第二学期
        CareerPlanResponse.Semester semester2 = new CareerPlanResponse.Semester();
        semester2.setSemester("大二下");

        // 技能
        CareerPlanResponse.Skill skill2 = new CareerPlanResponse.Skill();
        skill2.setName("JavaScript");
        skill2.setSemesterGoal("掌握" + difficultyLevel + "JavaScript编程与DOM操作");
        skill2.setStatus("未开始");
        skill2.setLearningResources("推荐课程：《JavaScript高级程序设计》、JavaScript.info");

        // 课程
        CareerPlanResponse.Course course2 = new CareerPlanResponse.Course();
        course2.setName("JavaScript编程");
        course2.setSemester("大二下");
        course2.setDifficulty("beginner".equals(weeklyStudyHours) ? 3 : "medium".equals(weeklyStudyHours) ? 4 : 5);
        course2.setEstimatedHours("low".equals(weeklyStudyHours) ? "40" : "medium".equals(weeklyStudyHours) ? "60" : "80");

        semester2.setSkills(List.of(skill2));
        semester2.setCourses(List.of(course2));
        semester2.setCertificates(new ArrayList<>());

        // 第三学期
        CareerPlanResponse.Semester semester3 = new CareerPlanResponse.Semester();
        semester3.setSemester("大三上");

        // 技能
        CareerPlanResponse.Skill skill3 = new CareerPlanResponse.Skill();
        skill3.setName("前端框架");
        skill3.setSemesterGoal("学习" + difficultyLevel + "React/Vue框架开发");
        skill3.setStatus("未开始");
        skill3.setLearningResources("推荐课程：React官方文档、Vue.js实战");

        // 证书
        CareerPlanResponse.Certificate cert = new CareerPlanResponse.Certificate();
        cert.setName("前端开发工程师认证");
        cert.setSemester("大三上");
        cert.setRecognition("beginner".equals(weeklyStudyHours) ? "中" : "高");
        cert.setCost("beginner".equals(weeklyStudyHours) ? "¥1,500" : "¥2,800");

        semester3.setSkills(List.of(skill3));
        semester3.setCourses(new ArrayList<>());
        semester3.setCertificates(List.of(cert));

        return List.of(semester1, semester2, semester3);
    }

    // 创建后端开发职业计划 - 旧版本
    private List<CareerPlanResponse.Semester> createBackendPlan(String difficultyLevel, String weeklyStudyHours) {
        // 实现后端开发计划
        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 第一学期
        CareerPlanResponse.Semester semester1 = new CareerPlanResponse.Semester();
        semester1.setSemester("大二上");

        // 技能
        CareerPlanResponse.Skill skill1 = new CareerPlanResponse.Skill();
        skill1.setName("Java基础");
        skill1.setSemesterGoal("掌握" + difficultyLevel + "Java核心语法和面向对象编程");
        skill1.setStatus("进行中");
        skill1.setLearningResources("推荐课程：《Java核心技术》、Java官方教程");

        // 课程
        CareerPlanResponse.Course course1 = new CareerPlanResponse.Course();
        course1.setName("Java程序设计");
        course1.setSemester("大二上");
        course1.setDifficulty("beginner".equals(weeklyStudyHours) ? 3 : "medium".equals(weeklyStudyHours) ? 4 : 5);
        course1.setEstimatedHours("low".equals(weeklyStudyHours) ? "45" : "medium".equals(weeklyStudyHours) ? "60" : "80");

        semester1.setSkills(List.of(skill1));
        semester1.setCourses(List.of(course1));
        semester1.setCertificates(new ArrayList<>());

        // 第二学期
        CareerPlanResponse.Semester semester2 = new CareerPlanResponse.Semester();
        semester2.setSemester("大二下");

        // 技能
        CareerPlanResponse.Skill skill2 = new CareerPlanResponse.Skill();
        skill2.setName("Spring框架");
        skill2.setSemesterGoal("学习" + difficultyLevel + "Spring Boot开发与应用");
        skill2.setStatus("未开始");
        skill2.setLearningResources("推荐课程：Spring官方文档、《Spring实战》");

        // 课程
        CareerPlanResponse.Course course2 = new CareerPlanResponse.Course();
        course2.setName("Spring框架入门");
        course2.setSemester("大二下");
        course2.setDifficulty("beginner".equals(weeklyStudyHours) ? 3 : "medium".equals(weeklyStudyHours) ? 4 : 5);
        course2.setEstimatedHours("low".equals(weeklyStudyHours) ? "50" : "medium".equals(weeklyStudyHours) ? "70" : "90");

        semester2.setSkills(List.of(skill2));
        semester2.setCourses(List.of(course2));
        semester2.setCertificates(new ArrayList<>());

        // 第三学期
        CareerPlanResponse.Semester semester3 = new CareerPlanResponse.Semester();
        semester3.setSemester("大三上");

        // 技能
        CareerPlanResponse.Skill skill3 = new CareerPlanResponse.Skill();
        skill3.setName("数据库设计");
        skill3.setSemesterGoal("掌握" + difficultyLevel + "SQL和数据库优化技术");
        skill3.setStatus("未开始");
        skill3.setLearningResources("推荐课程：《SQL必知必会》、《高性能MySQL》");

        // 证书
        CareerPlanResponse.Certificate cert = new CareerPlanResponse.Certificate();
        cert.setName("Java工程师认证");
        cert.setSemester("大三上");
        cert.setRecognition("beginner".equals(weeklyStudyHours) ? "中" : "高");
        cert.setCost("beginner".equals(weeklyStudyHours) ? "¥2,000" : "¥3,500");

        semester3.setSkills(List.of(skill3));
        semester3.setCourses(new ArrayList<>());
        semester3.setCertificates(List.of(cert));

        return List.of(semester1, semester2, semester3);
    }

    // 创建通用职业计划 - 旧版本
    private List<CareerPlanResponse.Semester> createGenericPlan(String difficultyLevel, String weeklyStudyHours) {
        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 第一学期
        CareerPlanResponse.Semester semester1 = new CareerPlanResponse.Semester();
        semester1.setSemester("大二上");

        // 技能
        CareerPlanResponse.Skill skill1 = new CareerPlanResponse.Skill();
        skill1.setName("编程基础");
        skill1.setSemesterGoal("掌握" + difficultyLevel + "编程基本概念与实践");
        skill1.setStatus("进行中");
        skill1.setLearningResources("推荐课程：《编程导论》、《算法入门》");

        // 课程
        CareerPlanResponse.Course course1 = new CareerPlanResponse.Course();
        course1.setName("程序设计基础");
        course1.setSemester("大二上");
        course1.setDifficulty("beginner".equals(weeklyStudyHours) ? 2 : "medium".equals(weeklyStudyHours) ? 3 : 4);
        course1.setEstimatedHours("low".equals(weeklyStudyHours) ? "40" : "medium".equals(weeklyStudyHours) ? "55" : "70");

        semester1.setSkills(List.of(skill1));
        semester1.setCourses(List.of(course1));
        semester1.setCertificates(new ArrayList<>());

        // 第二学期
        CareerPlanResponse.Semester semester2 = new CareerPlanResponse.Semester();
        semester2.setSemester("大二下");

        // 技能
        CareerPlanResponse.Skill skill2 = new CareerPlanResponse.Skill();
        skill2.setName("算法与数据结构");
        skill2.setSemesterGoal("学习" + difficultyLevel + "算法设计与优化技术");
        skill2.setStatus("未开始");
        skill2.setLearningResources("推荐课程：《算法导论》、LeetCode题库");

        // 课程
        CareerPlanResponse.Course course2 = new CareerPlanResponse.Course();
        course2.setName("数据结构与算法");
        course2.setSemester("大二下");
        course2.setDifficulty("beginner".equals(weeklyStudyHours) ? 3 : "medium".equals(weeklyStudyHours) ? 4 : 5);
        course2.setEstimatedHours("low".equals(weeklyStudyHours) ? "45" : "medium".equals(weeklyStudyHours) ? "65" : "85");

        semester2.setSkills(List.of(skill2));
        semester2.setCourses(List.of(course2));
        semester2.setCertificates(new ArrayList<>());

        // 第三学期
        CareerPlanResponse.Semester semester3 = new CareerPlanResponse.Semester();
        semester3.setSemester("大三上");

        // 技能
        CareerPlanResponse.Skill skill3 = new CareerPlanResponse.Skill();
        skill3.setName("专业领域技能");
        skill3.setSemesterGoal("掌握" + difficultyLevel + "专业技术与应用");
        skill3.setStatus("未开始");
        skill3.setLearningResources("推荐课程：领域专业书籍、实践项目");

        // 证书
        CareerPlanResponse.Certificate cert = new CareerPlanResponse.Certificate();
        cert.setName("软件开发工程师认证");
        cert.setSemester("大三上");
        cert.setRecognition("beginner".equals(weeklyStudyHours) ? "中" : "高");
        cert.setCost("beginner".equals(weeklyStudyHours) ? "¥1,800" : "¥3,000");

        semester3.setSkills(List.of(skill3));
        semester3.setCourses(new ArrayList<>());
        semester3.setCertificates(List.of(cert));

        return List.of(semester1, semester2, semester3);
    }

    // ==== 新版本的职业规划方法 - 考虑个性化信息 ====

    /**
     * 创建前端开发职业计划 - 新版本，考虑个性化信息
     */
    private List<CareerPlanResponse.Semester> createFrontendPlan(
            String startSemester, String intensity, List<String> knownSkills, String learningStyle) {

        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 所有可能的前端技能（按学习顺序）
        List<CareerPlanResponse.Skill> allSkills = new ArrayList<>();

        // 添加学习方法后缀
        String methodSuffix = getLearningSuffix(learningStyle);

        // 创建技能列表
        allSkills.add(createSkill("HTML/CSS", "掌握HTML5和CSS3基础" + methodSuffix));
        allSkills.add(createSkill("JavaScript", "掌握JavaScript和DOM编程" + methodSuffix));
        allSkills.add(createSkill("React", "学习React框架开发" + methodSuffix));
        allSkills.add(createSkill("Vue", "学习Vue框架开发" + methodSuffix));
        allSkills.add(createSkill("TypeScript", "掌握TypeScript开发" + methodSuffix));
        allSkills.add(createSkill("UI/UX设计", "学习基本的UI/UX设计原则" + methodSuffix));
        allSkills.add(createSkill("Node.js", "掌握Node.js基础" + methodSuffix));
        allSkills.add(createSkill("前端工程化", "学习Webpack、Vite等构建工具" + methodSuffix));

        // 过滤掉已掌握的技能
        if (knownSkills != null && !knownSkills.isEmpty()) {
            allSkills.removeIf(skill -> knownSkills.contains(skill.getName()));
        }

        // 确定每学期的技能数量
        int skillsPerSemester = getSkillsPerSemester(intensity);

        // 创建课程列表
        List<CareerPlanResponse.Course> allCourses = new ArrayList<>();
        allCourses.add(createCourse("Web前端开发基础", startSemester));
        allCourses.add(createCourse("JavaScript编程", getNextSemester(startSemester)));
        allCourses.add(createCourse("现代前端框架", getNextSemester(getNextSemester(startSemester))));

        // 创建证书列表
        List<CareerPlanResponse.Certificate> allCertificates = new ArrayList<>();
        allCertificates.add(createCertificate("前端开发工程师认证",
                getNextSemester(getNextSemester(startSemester))));

        // 创建学期规划
        String currentSemester = startSemester;
        int skillIndex = 0;

        while (skillIndex < allSkills.size()) {
            CareerPlanResponse.Semester semester = new CareerPlanResponse.Semester();
            semester.setSemester(currentSemester);

            // 分配当前学期的技能
            List<CareerPlanResponse.Skill> semesterSkills = new ArrayList<>();
            for (int i = 0; i < skillsPerSemester && skillIndex < allSkills.size(); i++) {
                CareerPlanResponse.Skill skill = allSkills.get(skillIndex++);

                // 设置第一个学期的第一个技能为"进行中"
                if (currentSemester.equals(startSemester) && i == 0) {
                    skill.setStatus("进行中");
                } else {
                    skill.setStatus("未开始");
                }

                semesterSkills.add(skill);
            }

            // 分配当前学期的课程
//            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
//                    .filter(course -> course.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());
//
//            // 分配当前学期的证书
//            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
//                    .filter(cert -> cert.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());

            // 创建一个final副本
            final String semesterName = currentSemester;

            // 分配当前学期的课程
            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
                    .filter(course -> course.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            // 分配当前学期的证书
            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
                    .filter(cert -> cert.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            semester.setSkills(semesterSkills);
            semester.setCourses(semesterCourses);
            semester.setCertificates(semesterCertificates);

            semesters.add(semester);
            currentSemester = getNextSemester(currentSemester);
        }

        return semesters;
    }

    /**
     * 创建后端开发职业计划 - 新版本，考虑个性化信息
     */
    private List<CareerPlanResponse.Semester> createBackendPlan(
            String startSemester, String intensity, List<String> knownSkills, String learningStyle) {

        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 添加学习方法后缀
        String methodSuffix = getLearningSuffix(learningStyle);

        // 所有可能的后端技能（按学习顺序）
        List<CareerPlanResponse.Skill> allSkills = new ArrayList<>();
        allSkills.add(createSkill("Java基础", "掌握Java核心语法和面向对象编程" + methodSuffix));
        allSkills.add(createSkill("Spring框架", "学习Spring Boot开发与应用" + methodSuffix));
        allSkills.add(createSkill("数据库设计", "掌握SQL和数据库优化技术" + methodSuffix));
        allSkills.add(createSkill("RESTful API", "掌握API设计与实现" + methodSuffix));
        allSkills.add(createSkill("微服务架构", "学习微服务设计原则与实践" + methodSuffix));
        allSkills.add(createSkill("容器技术", "学习Docker和Kubernetes" + methodSuffix));
        allSkills.add(createSkill("缓存与消息队列", "掌握Redis和消息队列技术" + methodSuffix));

        // 过滤掉已掌握的技能
        if (knownSkills != null && !knownSkills.isEmpty()) {
            allSkills.removeIf(skill -> knownSkills.contains(skill.getName()));
        }

        // 确定每学期的技能数量
        int skillsPerSemester = getSkillsPerSemester(intensity);

        // 创建课程列表
        List<CareerPlanResponse.Course> allCourses = new ArrayList<>();
        allCourses.add(createCourse("Java程序设计", startSemester));
        allCourses.add(createCourse("Spring框架入门", getNextSemester(startSemester)));
        allCourses.add(createCourse("企业级应用开发", getNextSemester(getNextSemester(startSemester))));

        // 创建证书列表
        List<CareerPlanResponse.Certificate> allCertificates = new ArrayList<>();
        allCertificates.add(createCertificate("Java工程师认证",
                getNextSemester(getNextSemester(startSemester))));

        // 创建学期规划
        String currentSemester = startSemester;
        int skillIndex = 0;

        while (skillIndex < allSkills.size()) {
            CareerPlanResponse.Semester semester = new CareerPlanResponse.Semester();
            semester.setSemester(currentSemester);

            // 分配当前学期的技能
            List<CareerPlanResponse.Skill> semesterSkills = new ArrayList<>();
            for (int i = 0; i < skillsPerSemester && skillIndex < allSkills.size(); i++) {
                CareerPlanResponse.Skill skill = allSkills.get(skillIndex++);

                // 设置第一个学期的第一个技能为"进行中"
                if (currentSemester.equals(startSemester) && i == 0) {
                    skill.setStatus("进行中");
                } else {
                    skill.setStatus("未开始");
                }

                semesterSkills.add(skill);
            }

            // 分配当前学期的课程
//            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
//                    .filter(course -> course.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());

            // 创建一个final副本
            final String semesterName = currentSemester;

            // 分配当前学期的课程
            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
                    .filter(course -> course.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            // 分配当前学期的证书
//            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
//                    .filter(cert -> cert.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());

            // 使用同一个final副本，不需要再次创建
            // 分配当前学期的证书
            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
                    .filter(cert -> cert.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            semester.setSkills(semesterSkills);
            semester.setCourses(semesterCourses);
            semester.setCertificates(semesterCertificates);

            semesters.add(semester);
            currentSemester = getNextSemester(currentSemester);
        }

        return semesters;
    }

    /**
     * 创建Python开发职业计划
     */
    private List<CareerPlanResponse.Semester> createPythonPlan(
            String startSemester, String intensity, List<String> knownSkills, String learningStyle) {

        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 添加学习方法后缀
        String methodSuffix = getLearningSuffix(learningStyle);

        // 所有可能的Python技能（按学习顺序）
        List<CareerPlanResponse.Skill> allSkills = new ArrayList<>();
        allSkills.add(createSkill("Python基础", "掌握Python核心语法和编程基础" + methodSuffix));
        allSkills.add(createSkill("数据分析库", "学习NumPy、Pandas等数据分析库" + methodSuffix));
        allSkills.add(createSkill("Web开发", "掌握Flask或Django框架" + methodSuffix));
        allSkills.add(createSkill("数据可视化", "学习Matplotlib和Seaborn库" + methodSuffix));
        allSkills.add(createSkill("机器学习基础", "掌握scikit-learn库和基本算法" + methodSuffix));
        allSkills.add(createSkill("自动化脚本", "学习Python自动化工具开发" + methodSuffix));
        allSkills.add(createSkill("深度学习", "掌握TensorFlow或PyTorch框架" + methodSuffix));

        // 过滤掉已掌握的技能
        if (knownSkills != null && !knownSkills.isEmpty()) {
            allSkills.removeIf(skill -> knownSkills.contains(skill.getName()));
        }

        // 确定每学期的技能数量
        int skillsPerSemester = getSkillsPerSemester(intensity);

        // 创建课程列表
        List<CareerPlanResponse.Course> allCourses = new ArrayList<>();
        allCourses.add(createCourse("Python程序设计", startSemester));
        allCourses.add(createCourse("数据科学基础", getNextSemester(startSemester)));
        allCourses.add(createCourse("Python Web开发", getNextSemester(getNextSemester(startSemester))));

        // 创建证书列表
        List<CareerPlanResponse.Certificate> allCertificates = new ArrayList<>();
        allCertificates.add(createCertificate("Python开发工程师认证",
                getNextSemester(getNextSemester(startSemester))));

        // 创建学期规划（与前端和后端相似的逻辑）
        String currentSemester = startSemester;
        int skillIndex = 0;

        while (skillIndex < allSkills.size()) {
            CareerPlanResponse.Semester semester = new CareerPlanResponse.Semester();
            semester.setSemester(currentSemester);

            // 分配当前学期的技能
            List<CareerPlanResponse.Skill> semesterSkills = new ArrayList<>();
            for (int i = 0; i < skillsPerSemester && skillIndex < allSkills.size(); i++) {
                CareerPlanResponse.Skill skill = allSkills.get(skillIndex++);

                if (currentSemester.equals(startSemester) && i == 0) {
                    skill.setStatus("进行中");
                } else {
                    skill.setStatus("未开始");
                }

                semesterSkills.add(skill);
            }

            // 分配当前学期的课程
//            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
//                    .filter(course -> course.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());
//
//            // 分配当前学期的证书
//            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
//                    .filter(cert -> cert.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());

            // 在使用lambda表达式前创建final副本
            final String semesterName = currentSemester;

            // 分配当前学期的课程
            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
                    .filter(course -> course.getSemester().equals(semesterName))  // 使用final副本而非currentSemester
                    .collect(Collectors.toList());

            // 分配当前学期的证书
            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
                    .filter(cert -> cert.getSemester().equals(semesterName))  // 使用final副本而非currentSemester
                    .collect(Collectors.toList());

            semester.setSkills(semesterSkills);
            semester.setCourses(semesterCourses);
            semester.setCertificates(semesterCertificates);

            semesters.add(semester);
            currentSemester = getNextSemester(currentSemester);
        }

        return semesters;
    }

    /**
     * 创建通用职业计划 - 新版本，考虑个性化信息
     */
    private List<CareerPlanResponse.Semester> createGenericPlan(
            String startSemester, String intensity, List<String> knownSkills, String learningStyle) {

        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();

        // 添加学习方法后缀
        String methodSuffix = getLearningSuffix(learningStyle);

        // 所有可能的通用技能（按学习顺序）
        List<CareerPlanResponse.Skill> allSkills = new ArrayList<>();
        allSkills.add(createSkill("编程基础", "掌握编程基本概念与实践" + methodSuffix));
        allSkills.add(createSkill("算法与数据结构", "学习常用算法和数据结构" + methodSuffix));
        allSkills.add(createSkill("软件工程", "掌握软件开发流程和最佳实践" + methodSuffix));
        allSkills.add(createSkill("版本控制", "掌握Git工作流" + methodSuffix));
        allSkills.add(createSkill("数据库基础", "学习SQL和数据库设计" + methodSuffix));
        allSkills.add(createSkill("Web开发基础", "学习前后端交互原理" + methodSuffix));
        allSkills.add(createSkill("项目管理", "掌握敏捷开发和项目管理方法" + methodSuffix));

        // 过滤掉已掌握的技能
        if (knownSkills != null && !knownSkills.isEmpty()) {
            allSkills.removeIf(skill -> knownSkills.contains(skill.getName()));
        }

        // 确定每学期的技能数量
        int skillsPerSemester = getSkillsPerSemester(intensity);

        // 创建课程列表
        List<CareerPlanResponse.Course> allCourses = new ArrayList<>();
        allCourses.add(createCourse("程序设计基础", startSemester));
        allCourses.add(createCourse("数据结构与算法", getNextSemester(startSemester)));
        allCourses.add(createCourse("软件工程导论", getNextSemester(getNextSemester(startSemester))));

        // 创建证书列表
        List<CareerPlanResponse.Certificate> allCertificates = new ArrayList<>();
        allCertificates.add(createCertificate("软件开发工程师认证",
                getNextSemester(getNextSemester(startSemester))));

        // 创建学期规划
        String currentSemester = startSemester;
        int skillIndex = 0;

        while (skillIndex < allSkills.size()) {
            CareerPlanResponse.Semester semester = new CareerPlanResponse.Semester();
            semester.setSemester(currentSemester);

            // 分配当前学期的技能
            List<CareerPlanResponse.Skill> semesterSkills = new ArrayList<>();
            for (int i = 0; i < skillsPerSemester && skillIndex < allSkills.size(); i++) {
                CareerPlanResponse.Skill skill = allSkills.get(skillIndex++);

                // 设置第一个学期的第一个技能为"进行中"
                if (currentSemester.equals(startSemester) && i == 0) {
                    skill.setStatus("进行中");
                } else {
                    skill.setStatus("未开始");
                }

                semesterSkills.add(skill);
            }

            // 分配当前学期的课程
//            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
//                    .filter(course -> course.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());
//
//            // 分配当前学期的证书
//            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
//                    .filter(cert -> cert.getSemester().equals(currentSemester))
//                    .collect(Collectors.toList());

            // 创建final副本
            final String semesterName = currentSemester;

            // 分配当前学期的课程
            List<CareerPlanResponse.Course> semesterCourses = allCourses.stream()
                    .filter(course -> course.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            // 分配当前学期的证书
            List<CareerPlanResponse.Certificate> semesterCertificates = allCertificates.stream()
                    .filter(cert -> cert.getSemester().equals(semesterName))  // 使用final副本
                    .collect(Collectors.toList());

            semester.setSkills(semesterSkills);
            semester.setCourses(semesterCourses);
            semester.setCertificates(semesterCertificates);

            semesters.add(semester);
            currentSemester = getNextSemester(currentSemester);
        }

        return semesters;
    }

    /**
     * 辅助方法：创建技能对象
     */
    private CareerPlanResponse.Skill createSkill(String name, String goal) {
        CareerPlanResponse.Skill skill = new CareerPlanResponse.Skill();
        skill.setName(name);
        skill.setSemesterGoal(goal);
        skill.setStatus("未开始");
        skill.setLearningResources("推荐相关课程和资料");
        return skill;

    }

    /**
     * 辅助方法：创建技能对象
     */
//    private CareerPlanResponse.Skill createSkill(String name, String goal) {
//        CareerPlanResponse.Skill skill = new CareerPlanResponse.Skill();
//        skill.setName(name);
//        skill.setSemesterGoal(goal);
//        skill.setStatus("未开始");
//        skill.setLearningResources("推荐相关课程和资料");
//        return skill;
//    }

    /**
     * 辅助方法：创建课程对象
     */
    private CareerPlanResponse.Course createCourse(String name, String semester) {
        CareerPlanResponse.Course course = new CareerPlanResponse.Course();
        course.setName(name);
        course.setSemester(semester);
        course.setDifficulty(3); // 默认中等难度
        course.setEstimatedHours("40-60小时");
        return course;
    }

    /**
     * 辅助方法：创建证书对象
     */
    private CareerPlanResponse.Certificate createCertificate(String name, String semester) {
        CareerPlanResponse.Certificate cert = new CareerPlanResponse.Certificate();
        cert.setName(name);
        cert.setSemester(semester);
        cert.setRecognition("高");
        cert.setCost("¥2,000-3,000");
        return cert;
    }

    /**
     * 辅助方法：获取下一个学期
     */
    private String getNextSemester(String currentSemester) {
        if (currentSemester.endsWith("上")) {
            return currentSemester.replace("上", "下");
        } else if (currentSemester.endsWith("下")) {
            int year = Integer.parseInt(currentSemester.substring(1, 2));
            return "大" + (year + 1) + "上";
        }
        return "下一学期"; // 默认
    }

    /**
     * 辅助方法：根据学习强度确定每学期技能数量
     */
    private int getSkillsPerSemester(String intensity) {
        if (intensity == null) {
            return 2; // 默认
        }

        switch (intensity) {
            case "轻松":
                return 1;
            case "适中":
                return 2;
            case "强化":
                return 3;
            case "密集":
                return 4;
            default:
                return 2; // 默认
        }
    }

    /**
     * 辅助方法：根据学习风格获取学习方法后缀
     */
    private String getLearningSuffix(String learningStyle) {
        if (learningStyle == null) {
            return "";
        }

        switch (learningStyle) {
            case "视觉型":
                return "，通过视频教程和图表学习";
            case "听觉型":
                return "，通过讲座和音频资料学习";
            case "实践型":
                return "，通过实践项目和练习学习";
            case "阅读型":
                return "，通过阅读书籍和文档学习";
            default:
                return "";
        }
    }

    // 通义千问API请求和响应类
//    @Data
//    public static class QianwenRequest {
//        private String model;
//        private QianwenInput input;
//        private Map<String, Object> parameters = Map.of(
//                "temperature", 0.4,  // 降低温度以获得更一致的输出
//                "max_tokens", 2000,
//                "top_p", 0.8
//        );
//    }

    @Data
    public static class QianwenRequest {
        private String model;
        private QianwenInput input;

        @JsonProperty("task") // 添加这个注解确保字段被序列化
        private String task = "text_generation"; // 添加这一行，设置默认值
        private Map<String, Object> parameters = Map.of(
                "temperature", 0.4,
                "max_tokens", 2000,
                "top_p", 0.8
        );
    }

    @Data
    public static class QianwenInput {
        private String prompt;

        public QianwenInput(String prompt) {
            this.prompt = prompt;
        }
    }

    @Data
    public static class QianwenResponse {
        private String request_id;
        private QianwenOutput output;
        private QianwenUsage usage;
    }

    @Data
    public static class QianwenOutput {
        private String text;
        private String finish_reason;
    }

    @Data
    public static class QianwenUsage {
        private int input_tokens;
        private int output_tokens;
    }
}