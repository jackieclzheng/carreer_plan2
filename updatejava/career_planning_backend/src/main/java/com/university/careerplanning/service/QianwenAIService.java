package com.university.careerplanning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.dto.SkillUpdateRequest;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class QianwenAIService {

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
    
    // 预定义的职业方向列表
    private static final List<Map<String, Object>> CAREER_DIRECTIONS = List.of(
        Map.of("id", 1, "title", "前端开发工程师", "description", "专注于Web前端开发技术"),
        Map.of("id", 2, "title", "后端开发工程师", "description", "Java企业级应用开发"),
        Map.of("id", 3, "title", "Python开发工程师", "description", "Python应用开发和数据分析"),
        Map.of("id", 4, "title", "全栈开发工程师", "description", "前后端全栈开发技术"),
        Map.of("id", 5, "title", "数据工程师", "description", "大数据处理和分析"),
        Map.of("id", 6, "title", "DevOps工程师", "description", "开发运维一体化")
    );
    
    public List<Map<String, Object>> getCareerDirections() {
        return CAREER_DIRECTIONS;
    }
    
    public CareerPlanResponse generatePersonalizedPlan(CareerPlanRequest request) {
        try {
            // 构建请求通义千问API的参数
            QianwenRequest qianwenRequest = new QianwenRequest();
            qianwenRequest.setModel(modelName);
            
            // 构建提示词
            String prompt = buildPrompt(request);
            qianwenRequest.setInput(new QianwenInput(prompt));
            
            // 配置通义千问API请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + qianwenApiKey);
            
            // 发送请求到通义千问API
            HttpEntity<QianwenRequest> requestEntity = new HttpEntity<>(qianwenRequest, headers);
            QianwenResponse qianwenResponse = restTemplate.postForObject(
                qianwenApiUrl, 
                requestEntity, 
                QianwenResponse.class
            );
            
            // 解析通义千问的响应获取生成的职业规划
            if (qianwenResponse != null && qianwenResponse.getOutput() != null) {
                String generatedPlan = qianwenResponse.getOutput().getText();
                
                // 尝试将文本解析为JSON并转换为CareerPlanResponse对象
                CareerPlanResponse plan = parseGeneratedPlan(generatedPlan, request);
                
                // 保存用户的规划以便后续更新
                String userId = "user-" + System.currentTimeMillis(); // 这里应该使用实际的用户ID
                userPlans.put(userId, plan);
                
                return plan;
            } else {
                // 返回备用规划数据
                return generateFallbackPlan(request);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 返回备用规划数据
            return generateFallbackPlan(request);
        }
    }
    
    public void updateSkillStatus(SkillUpdateRequest request) {
        // 在实际应用中，这里应该更新数据库中的技能状态
        // 这里仅作为示例，更新内存中的计划
        
        // 查找最近生成的一个计划并更新 (简化，实际应基于用户ID)
        if (!userPlans.isEmpty()) {
            CareerPlanResponse plan = userPlans.values().iterator().next();
            if (plan.getSemesters().size() > request.getSemesterIndex()) {
                CareerPlanResponse.Semester semester = plan.getSemesters().get(request.getSemesterIndex());
                if (semester.getSkills().size() > request.getSkillIndex()) {
                    semester.getSkills().get(request.getSkillIndex()).setStatus(request.getNewStatus());
                }
            }
        }
    }
    
    private String buildPrompt(CareerPlanRequest request) {
        // 根据用户选择的职业方向ID获取职业名称
        String careerTitle = CAREER_DIRECTIONS.stream()
            .filter(career -> career.get("id").equals(request.getSelectedCareer()))
            .map(career -> career.get("title").toString())
            .findFirst()
            .orElse("软件工程师");
        
        // 构建提示词
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位职业规划和技术发展专家。请根据以下信息，为用户生成一份详细的个性化职业规划：\n\n");
        prompt.append("目标职业：").append(careerTitle).append("\n");
        prompt.append("规划时长：").append(request.getPlanDuration()).append("（short=短期1年，medium=中期2-3年，long=长期4-5年）\n");
        prompt.append("当前技能水平：").append(request.getSkillLevel()).append("（beginner=初学者，intermediate=中级，advanced=高级）\n");
        prompt.append("兴趣领域ID：").append(request.getInterests()).append("\n");
        prompt.append("每周学习时间：").append(request.getWeeklyStudyHours()).append("（low=5-10小时/周，medium=10-20小时/周，high=20+小时/周）\n\n");
        
        prompt.append("请生成一个详细的JSON格式的职业规划，包含以下内容：\n");
        prompt.append("1. targetCareer: 目标职业名称\n");
        prompt.append("2. careerPath: 职业发展路径\n");
        prompt.append("3. estimatedTime: 预计达成时间\n");
        prompt.append("4. corePower: 核心竞争力\n");
        prompt.append("5. learningIntensity: 学习强度\n");
        prompt.append("6. skillLevel: 技能水平\n");
        prompt.append("7. semesters: 学期规划列表，每学期包含：\n");
        prompt.append("   - semester: 学期名称（如'大二上'）\n");
        prompt.append("   - skills: 技能列表，每个技能包含name, semesterGoal, status, learningResources\n");
        prompt.append("   - courses: 课程列表，每个课程包含name, semester, difficulty, estimatedHours\n");
        prompt.append("   - certificates: 证书列表，每个证书包含name, semester, recognition, cost\n\n");
        
        prompt.append("请确保JSON有效，并根据用户的技能水平、规划时长和学习时间调整内容的难度和密度。");
        
        return prompt.toString();
    }
    
    private CareerPlanResponse parseGeneratedPlan(String generatedText, CareerPlanRequest request) {
        try {
            // 从生成的文本中提取JSON部分
            String jsonPart = extractJsonFromText(generatedText);
            
            // 解析JSON为CareerPlanResponse对象
            return objectMapper.readValue(jsonPart, CareerPlanResponse.class);
        } catch (Exception e) {
            e.printStackTrace();
            // 解析失败，返回备用计划
            return generateFallbackPlan(request);
        }
    }
    
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
    
    // 生成备用的职业规划，当API调用失败时使用
    private CareerPlanResponse generateFallbackPlan(CareerPlanRequest request) {
        // 获取职业名称
        String careerTitle = CAREER_DIRECTIONS.stream()
            .filter(career -> career.get("id").equals(request.getSelectedCareer()))
            .map(career -> career.get("title").toString())
            .findFirst()
            .orElse("软件工程师");
        
        // 根据技能水平调整内容
        String difficultyLevel = "beginner".equals(request.getSkillLevel()) ? "基础" : 
                                "intermediate".equals(request.getSkillLevel()) ? "进阶" : "高级";
        
        // 根据规划时长调整
        String planYears = "short".equals(request.getPlanDuration()) ? "1" : 
                           "medium".equals(request.getPlanDuration()) ? "2-3" : "4-5";
        
        // 根据学习时间设置内容密度
        String contentDensity = "low".equals(request.getWeeklyStudyHours()) ? "基础" : 
                                "medium".equals(request.getWeeklyStudyHours()) ? "标准" : "密集";
        
        // 创建备用规划
        CareerPlanResponse response = new CareerPlanResponse();
        response.setTargetCareer(careerTitle);
        response.setCareerPath("初级" + careerTitle + " → 中级" + careerTitle + " → 高级" + careerTitle + " → 技术专家/架构师");
        response.setEstimatedTime(planYears + "年");
        response.setCorePower(careerTitle.contains("前端") ? "UI/UX设计能力、交互设计能力、前端框架精通" : 
                             careerTitle.contains("后端") ? "系统架构设计、数据库优化、高并发处理" : 
                             "全栈技术、项目管理、问题解决能力");
        response.setLearningIntensity(contentDensity);
        response.setSkillLevel(difficultyLevel);
        
        // 创建学期规划
        List<CareerPlanResponse.Semester> semesters = new ArrayList<>();
        
        // 创建技能、课程和证书
        if (request.getSelectedCareer() == 1) { // 前端
            semesters = createFrontendPlan(difficultyLevel, request.getWeeklyStudyHours());
        } else if (request.getSelectedCareer() == 2) { // 后端
            semesters = createBackendPlan(difficultyLevel, request.getWeeklyStudyHours());
        } else {
            semesters = createGenericPlan(difficultyLevel, request.getWeeklyStudyHours());
        }
        
        response.setSemesters(semesters);
        return response;
    }
    
    // 创建前端开发职业计划
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
    
    // 创建后端开发职业计划
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
    
    // 创建通用职业计划
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
    
    // 通义千问API请求和响应类
    @Data
    public static class QianwenRequest {
        private String model;
        private QianwenInput input;
        private Map<String, Object> parameters = Map.of(
            "temperature", 0.7,
            "max_tokens", 2000
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
