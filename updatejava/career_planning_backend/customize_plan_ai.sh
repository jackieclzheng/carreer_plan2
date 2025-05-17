#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}开始创建通义千问职业规划系统文件...${NC}"

# 创建目录结构
mkdir -p src/main/java/com/university/careerplanning/{controller,service,dto,model,config,exception}
mkdir -p src/main/resources
mkdir -p src/test/java/com/university/careerplanning/{service,controller,integration}

# 创建主应用类
cat > src/main/java/com/university/careerplanning/CareerPlanningApplication.java << 'EOF'
package com.university.careerplanning;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CareerPlanningApplication {
    public static void main(String[] args) {
        SpringApplication.run(CareerPlanningApplication.class, args);
    }
}
EOF

# 创建DTO文件
cat > src/main/java/com/university/careerplanning/dto/CareerPlanRequest.java << 'EOF'
package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

@Data
public class CareerPlanRequest {
    private Integer selectedCareer; // 所选职业方向ID
    private String planDuration;    // 规划时长: short, medium, long
    private String skillLevel;      // 技能水平: beginner, intermediate, advanced
    private List<Integer> interests; // 兴趣领域ID列表
    private String weeklyStudyHours; // 每周学习时间: low, medium, high
}
EOF

cat > src/main/java/com/university/careerplanning/dto/SkillUpdateRequest.java << 'EOF'
package com.university.careerplanning.dto;

import lombok.Data;

@Data
public class SkillUpdateRequest {
    private int semesterIndex;
    private int skillIndex;
    private String newStatus;
}
EOF

cat > src/main/java/com/university/careerplanning/dto/CareerPlanResponse.java << 'EOF'
package com.university.careerplanning.dto;

import java.util.List;
import lombok.Data;

@Data
public class CareerPlanResponse {
    private String targetCareer;      // 目标职业
    private String careerPath;        // 职业发展路径
    private String estimatedTime;     // 预计达成时间
    private String corePower;         // 核心竞争力
    private String learningIntensity; // 学习强度
    private String skillLevel;        // 技能水平
    private List<Semester> semesters; // 学期规划列表
    
    @Data
    public static class Semester {
        private String semester;
        private List<Skill> skills;
        private List<Course> courses;
        private List<Certificate> certificates;
    }
    
    @Data
    public static class Skill {
        private String name;
        private String semesterGoal;
        private String status;
        private String learningResources;
    }
    
    @Data
    public static class Course {
        private String name;
        private String semester;
        private int difficulty;
        private String estimatedHours;
    }
    
    @Data
    public static class Certificate {
        private String name;
        private String semester;
        private String recognition;
        private String cost;
    }
}
EOF

# 创建controller
cat > src/main/java/com/university/careerplanning/controller/CareerPlanningController.java << 'EOF'
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.dto.SkillUpdateRequest;
import com.university.careerplanning.service.QianwenAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/career-planning")
@CrossOrigin(origins = "*") // 允许跨域请求
public class CareerPlanningController {
    
    @Autowired
    private QianwenAIService qianwenAIService;
    
    @PostMapping("/plan")
    public ResponseEntity<CareerPlanResponse> generateCareerPlan(@RequestBody CareerPlanRequest request) {
        // 调用通义千问服务生成职业规划
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/directions")
    public ResponseEntity<?> getCareerDirections() {
        // 返回预定义的职业方向列表
        return ResponseEntity.ok(qianwenAIService.getCareerDirections());
    }
    
    @PatchMapping("/plan/skills")
    public ResponseEntity<?> updateSkillStatus(@RequestBody SkillUpdateRequest request) {
        // 存储用户技能状态更新（可以保存到数据库）
        qianwenAIService.updateSkillStatus(request);
        return ResponseEntity.ok().build();
    }
}
EOF

# 创建service
cat > src/main/java/com/university/careerplanning/service/QianwenAIService.java << 'EOF'
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
EOF

# 创建application.yml配置文件
cat > src/main/resources/application.yml << 'EOF'
spring:
  application:
    name: career-planning-platform

server:
  port: 8080
  servlet:
    context-path: /

# 通义千问API配置
qianwen:
  api:
    url: https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation
    key: ${QIANWEN_API_KEY:your_default_key_for_development} # 请使用环境变量配置
  model:
    name: qwen-plus # 或使用其他可用模型

# 跨域配置
cors:
  allowed-origins: "*"
  allowed-methods: "GET,POST,PUT,DELETE,OPTIONS,PATCH"
  allowed-headers: "*"

# 日志配置
logging:
  level:
    root: INFO
    com.university.careerplanning: DEBUG
EOF

# 创建测试文件
cat > src/test/java/com/university/careerplanning/service/QianwenAIServiceTest.java << 'EOF'
package com.university.careerplanning.service;

import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.web.client.RestTemplate;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class QianwenAIServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private QianwenAIService qianwenAIService;

    @Test
    public void testGeneratePersonalizedPlan() {
        // 准备测试数据
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1);  // 前端开发工程师
        request.setPlanDuration("medium");  // 中期规划
        request.setSkillLevel("intermediate");  // 中级技能水平
        request.setInterests(List.of(1, 3));  // 感兴趣的领域ID
        request.setWeeklyStudyHours("medium");  // 每周学习时间
        
        // Mock通义千问API响应
        QianwenAIService.QianwenResponse mockResponse = new QianwenAIService.QianwenResponse();
        QianwenAIService.QianwenOutput output = new QianwenAIService.QianwenOutput();
        output.setText("以下是个性化职业规划：\n\n```json\n" +
                "{\n" +
                "  \"targetCareer\": \"前端开发工程师\",\n" +
                "  \"careerPath\": \"初级前端工程师 → 中级前端工程师 → 高级前端工程师 → 前端架构师\",\n" +
                "  \"estimatedTime\": \"2-3年\",\n" +
                "  \"corePower\": \"UI/UX设计能力、JavaScript深度理解、框架应用能力\",\n" +
                "  \"learningIntensity\": \"标准\",\n" +
                "  \"skillLevel\": \"进阶\",\n" +
                "  \"semesters\": [\n" +
                "    {\n" +
                "      \"semester\": \"大二上\",\n" +
                "      \"skills\": [\n" +
                "        {\n" +
                "          \"name\": \"HTML/CSS\",\n" +
                "          \"semesterGoal\": \"掌握进阶HTML5和CSS3技术\",\n" +
                "          \"status\": \"进行中\",\n" +
                "          \"learningResources\": \"推荐课程：《现代HTML与CSS实战》、MDN Web文档\"\n" +
                "        }\n" +
                "      ],\n" +
                "      \"courses\": [\n" +
                "        {\n" +
                "          \"name\": \"Web前端开发基础\",\n" +
                "          \"semester\": \"大二上\",\n" +
                "          \"difficulty\": 3,\n" +
                "          \"estimatedHours\": \"45\"\n" +
                "        }\n" +
                "      ],\n" +
                "      \"certificates\": []\n" +
                "    }\n" +
                "  ]\n" +
                "}\n" +
                "```");
        mockResponse.setOutput(output);
        
        // Mock RestTemplate调用
        when(restTemplate.postForObject(
                anyString(),
                any(HttpEntity.class),
                ArgumentMatchers.<Class<QianwenAIService.QianwenResponse>>any()
        )).thenReturn(mockResponse);
        
        // 执行测试
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        
        // 验证结果
        assertNotNull(response, "职业规划响应不应为空");
        assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");
        assertEquals("2-3年", response.getEstimatedTime(), "预计时间应匹配");
        assertTrue(response.getCareerPath().contains("初级前端工程师"), "职业路径应包含正确的职业阶段");
        assertNotNull(response.getSemesters(), "学期规划列表不应为空");
        
        if (!response.getSemesters().isEmpty()) {
            CareerPlanResponse.Semester firstSemester = response.getSemesters().get(0);
            assertEquals("大二上", firstSemester.getSemester(), "第一学期应为大二上");
            
            if (firstSemester.getSkills() != null && !firstSemester.getSkills().isEmpty()) {
                CareerPlanResponse.Skill firstSkill = firstSemester.getSkills().get(0);
                assertEquals("HTML/CSS", firstSkill.getName(), "第一技能应为HTML/CSS");
                assertEquals("进行中", firstSkill.getStatus(), "技能状态应为进行中");
            }
        }
    }
    
    @Test
    public void testGeneratePersonalizedPlanWithApiFailure() {
        // 准备测试数据
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1);
        request.setPlanDuration("medium");
        request.setSkillLevel("beginner");
        request.setWeeklyStudyHours("low");
        
        // Mock RestTemplate抛出异常
        when(restTemplate.postForObject(
                anyString(),
                any(HttpEntity.class),
                ArgumentMatchers.<Class<QianwenAIService.QianwenResponse>>any()
        )).thenThrow(new RuntimeException("API调用失败"));
        
        // 执行测试
        CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);
        
        // 验证结果 - 应返回备用计划
        assertNotNull(response, "API失败时应返回备用计划");
        assertEquals("前端开发工程师", response.getTargetCareer(), "备用计划应包含正确的职业标题");
        assertNotNull(response.getSemesters(), "备用计划应包含学期规划");
    }
    
    @Test
    public void testGetCareerDirections() {
        // 执行测试
        List<Map<String, Object>> directions = qianwenAIService.getCareerDirections();
        
        // 验证结果
        assertNotNull(directions, "职业方向列表不应为空");
        assertFalse(directions.isEmpty(), "职业方向列表应包含项目");
        assertEquals(6, directions.size(), "应有6个预定义的职业方向");
        
        // 验证第一个职业方向
        Map<String, Object> firstDirection = directions.get(0);
        assertEquals(1, firstDirection.get("id"), "第一个职业方向ID应为1");
        assertEquals("前端开发工程师", firstDirection.get("title"), "第一个职业方向标题应为前端开发工程师");
    }
}
EOF

# 创建控制器测试文件
cat > src/test/java/com/university/careerplanning/controller/CareerPlanningControllerTest.java << 'EOF'
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
EOF

# 创建端到端测试
cat > src/test/java/com/university/careerplanning/integration/CareerPlanningE2ETest.java << 'EOF'
package com.university.careerplanning.integration;

import com.university.careerplanning.CareerPlanningApplication;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 注意：此测试需要有效的通义千问API密钥
 * 请在测试前确保已设置环境变量或配置
 */
@SpringBootTest(
        classes = CareerPlanningApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
@ActiveProfiles("test") // 使用测试配置文件
public class CareerPlanningE2ETest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void testRealQianwenApiIntegration() {
        // 检查环境变量是否设置
        String apiKey = System.getenv("QIANWEN_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            System.out.println("警告: 未设置QIANWEN_API_KEY环境变量，将使用备用计划");
        }

        // 创建请求数据
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1);
        request.setPlanDuration("medium");
        request.setSkillLevel("intermediate");
        request.setInterests(List.of(1, 3));
        request.setWeeklyStudyHours("medium");

        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<CareerPlanRequest> requestEntity = new HttpEntity<>(request, headers);

        // 发送请求
        String url = "http://localhost:" + port + "/api/career-planning/plan";
        ResponseEntity<CareerPlanResponse> responseEntity = restTemplate.postForEntity(
                url, requestEntity, CareerPlanResponse.class);

        // 验证响应
        assertTrue(responseEntity.getStatusCode().is2xxSuccessful(), "请求应该成功");
        CareerPlanResponse response = responseEntity.getBody();
        assertNotNull(response, "响应不应为空");
        
        // 基本验证 - 无论是真实API响应还是备用计划都应满足
        assertNotNull(response.getTargetCareer(), "目标职业不应为空");
        assertNotNull(response.getCareerPath(), "职业路径不应为空");
        assertNotNull(response.getSemesters(), "学期计划不应为空");
        
        // 打印响应用于手动验证
        System.out.println("API响应成功! 目标职业: " + response.getTargetCareer());
        System.out.println("职业路径: " + response.getCareerPath());
        System.out.println("学期数量: " + response.getSemesters().size());
    }
    
    @Test
    public void testGetCareerDirections() {
        // 发送GET请求
        String url = "http://localhost:" + port + "/api/career-planning/directions";
        ResponseEntity<Object[]> responseEntity = restTemplate.getForEntity(url, Object[].class);
        
        // 验证响应
        assertTrue(responseEntity.getStatusCode().is2xxSuccessful());
        Object[] directions = responseEntity.getBody();
        assertNotNull(directions);
        assertTrue(directions.length > 0, "应返回至少一个职业方向");
    }
}
EOF

# 创建测试配置文件
cat > src/test/resources/application-test.yml << 'EOF'
spring:
  application:
    name: career-planning-platform-test

# 测试环境配置
qianwen:
  api:
    key: ${QIANWEN_API_KEY:test_key_for_testing}

# 日志配置
logging:
  level:
    root: INFO
    com.university.careerplanning: DEBUG
    org.springframework.web: DEBUG
EOF

# 创建前端Vue文件 - 职业规划组件
cat > src/main/resources/static/PersonalizedCareerPlanningView.vue << 'EOF'
<template>
  <div class="container mx-auto p-4">
    <Card class="w-full max-w-5xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <Target class="mr-2" /> 个性化职业规划定制
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div v-if="error" class="mb-4 p-4 bg-red-100 text-red-700 rounded">
          {{ error }}
        </div>

        <!-- 职业信息定制区域 -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div>
            <!-- 职业方向选择 -->
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                选择职业方向
              </Label>
              <select 
                v-model="selectedCareer" 
                @change="onCareerChange"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="" disabled>请选择职业方向</option>
                <option 
                  v-for="career in careerDirections" 
                  :key="career.id" 
                  :value="career.id"
                >
                  {{ career.title }}
                </option>
              </select>
            </div>
            
            <!-- 新增：职业规划时长 -->
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                规划时长
              </Label>
              <select 
                v-model="planDuration" 
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="short">短期（1年）</option>
                <option value="medium">中期（2-3年）</option>
                <option value="long">长期（4-5年）</option>
              </select>
            </div>
            
            <!-- 新增：当前技能水平 -->
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                当前技能水平
              </Label>
              <select 
                v-model="skillLevel" 
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="beginner">初学者</option>
                <option value="intermediate">中级</option>
                <option value="advanced">高级</option>
              </select>
            </div>
            
            <!-- 新增：兴趣领域 -->
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                兴趣领域（可多选）
              </Label>
              <div class="grid grid-cols-2 gap-2">
                <div v-for="interest in interestAreas" :key="interest.id" class="flex items-center">
                  <input 
                    type="checkbox" 
                    :id="'interest-'+interest.id" 
                    v-model="selectedInterests" 
                    :value="interest.id"
                    class="h-4 w-4 text-blue-600 border-gray-300 rounded"
                  />
                  <label :for="'interest-'+interest.id" class="ml-2 text-sm text-gray-600">
                    {{ interest.name }}
                  </label>
                </div>
              </div>
            </div>
            
            <!-- 新增：学习时间偏好 -->
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                每周学习时间
              </Label>
              <select 
                v-model="weeklyStudyHours" 
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="low">较少（5-10小时/周）</option>
                <option value="medium">适中（10-20小时/周）</option>
                <option value="high">较多（20+小时/周）</option>
              </select>
            </div>
            
            <!-- 生成按钮 -->
            <Button 
              class="w-full"
              @click="generatePlanWithBackendRequest"
            >
              <div v-if="loading" class="mr-2 h-4 w-4 animate-spin rounded-full border-b-2 border-white"></div>
              <Compass v-else class="mr-2 h-4 w-4" /> 
              {{ loading ? '正在生成...' : '生成个性化职业规划' }}
            </Button>
          </div>
          
          <!-- 右侧信息区域 -->
          <div>
            <!-- 新增：职业成长预测 -->
            <div class="mb-4 bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-2">职业前景预测</h4>
              <div v-if="selectedCareerObject" class="text-sm text-gray-600">
                <p class="mb-2">{{ selectedCareerObject.title }}职业发展前景：</p>
                <div class="flex items-center mb-1">
                  <span class="w-24">薪资范围：</span>
                  <div class="w-full bg-gray-200 rounded-full h-2.5">
                    <div class="bg-green-600 h-2.5 rounded-full" style="width: 85%"></div>
                  </div>
                </div>
                <div class="flex items-center mb-1">
                  <span class="w-24">市场需求：</span>
                  <div class="w-full bg-gray-200 rounded-full h-2.5">
                    <div class="bg-blue-600 h-2.5 rounded-full" style="width: 75%"></div>
                  </div>
                </div>
                <div class="flex items-center">
                  <span class="w-24">发展空间：</span>
                  <div class="w-full bg-gray-200 rounded-full h-2.5">
                    <div class="bg-purple-600 h-2.5 rounded-full" style="width: 80%"></div>
                  </div>
                </div>
              </div>
              <div v-else class="text-sm text-gray-500 italic">
                请选择职业方向查看相关前景
              </div>
            </div>
            
            <!-- 职业规划指导 -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm text-gray-600 mb-2">职业规划指导</h4>
              <div class="space-y-2">
                <div class="flex items-center bg-white p-2 rounded">
                  <BookOpen class="mr-2 text-blue-500" />
                  <span class="text-sm">选择适合自己的职业方向</span>
                </div>
                <div class="flex items-center bg-white p-2 rounded">
                  <Award class="mr-2 text-green-500" />
                  <span class="text-sm">制定清晰的学习目标</span>
                </div>
                <div class="flex items-center bg-white p-2 rounded">
                  <Star class="mr-2 text-yellow-500" />
                  <span class="text-sm">持续跟踪和调整规划</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 职业规划详情 -->
        <template v-if="personalizedPlan">
          <div>
            <h3 class="text-xl font-semibold mb-4 flex items-center">
              <CheckCircle class="mr-2 text-green-600" /> 
              {{ personalizedPlan.targetCareer }}职业规划
            </h3>
            
            <!-- 新增：职业规划概览 -->
            <div class="mb-6 p-4 bg-blue-50 rounded-lg">
              <h4 class="text-lg font-medium mb-3 text-blue-800">规划概览</h4>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="bg-white p-3 rounded shadow-sm">
                  <h5 class="font-semibold text-sm text-gray-700 mb-2">职业发展路径</h5>
                  <p class="text-sm text-gray-600">{{ personalizedPlan.careerPath || '初级开发 → 中级开发 → 高级开发 → 架构师' }}</p>
                </div>
                <div class="bg-white p-3 rounded shadow-sm">
                  <h5 class="font-semibold text-sm text-gray-700 mb-2">预计达成时间</h5>
                  <p class="text-sm text-gray-600">{{ personalizedPlan.estimatedTime || '3年' }}</p>
                </div>
                <div class="bg-white p-3 rounded shadow-sm">
                  <h5 class="font-semibold text-sm text-gray-700 mb-2">核心竞争力</h5>
                  <p class="text-sm text-gray-600">{{ personalizedPlan.corePower || '前端技术栈精通、UI/UX设计能力' }}</p>
                </div>
              </div>
            </div>
            
            <!-- 学期规划 -->
            <div 
              v-for="(semester, semesterIndex) in personalizedPlan.semesters" 
              :key="semester.semester" 
              class="mb-6 p-4 bg-gray-50 rounded-lg"
            >
              <h4 class="text-lg font-medium mb-3">
                {{ semester.semester }}学期规划
              </h4>
              
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <!-- 技能模块 -->
                <div>
                  <h5 class="font-semibold mb-2">技能培养</h5>
                  <div 
                    v-for="(skill, skillIndex) in semester.skills" 
                    :key="skill.name" 
                    class="bg-white p-3 rounded mb-2 shadow-sm"
                  >
                    <div class="flex justify-between items-center mb-2">
                      <span class="font-medium">{{ skill.name }}</span>
                      <span 
                        :class="`
                          text-xs px-2 py-1 rounded 
                          ${skill.status === '进行中' ? 'bg-blue-100 text-blue-800' : 
                            skill.status === '已完成' ? 'bg-green-100 text-green-800' : 
                            'bg-red-100 text-red-800'}
                        `"
                      >
                        {{ skill.status }}
                      </span>
                    </div>
                    <div class="text-sm text-gray-600 mb-2">
                      目标：{{ skill.semesterGoal }}
                    </div>
                    <!-- 新增：详细学习资源 -->
                    <div class="text-xs text-gray-500 mb-2" v-if="skill.learningResources">
                      推荐资源：{{ skill.learningResources }}
                    </div>
                    <Select 
                      :value="skill.status"
                      @update:modelValue="(newStatus) => updateSkillStatus(semesterIndex, skillIndex, newStatus)"
                    >
                      <SelectTrigger class="w-full">
                        <SelectValue placeholder="更新状态" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="未开始">未开始</SelectItem>
                        <SelectItem value="进行中">进行中</SelectItem>
                        <SelectItem value="已完成">已完成</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <!-- 课程模块 -->
                <div>
                  <h5 class="font-semibold mb-2">推荐课程</h5>
                  <template v-if="semester.courses && semester.courses.length > 0">
                    <div 
                      v-for="course in semester.courses" 
                      :key="course.name" 
                      class="bg-white p-3 rounded mb-2 shadow-sm"
                    >
                      <div class="flex justify-between items-center mb-1">
                        <span class="font-medium">{{ course.name }}</span>
                        <span class="text-sm text-gray-600">
                          {{ course.semester }}
                        </span>
                      </div>
                      <!-- 新增：课程难度指示 -->
                      <div class="flex items-center mb-1">
                        <span class="text-xs text-gray-500 mr-2">难度：</span>
                        <div class="flex">
                          <span v-for="i in 5" :key="i" class="text-xs">
                            <span v-if="i <= (course.difficulty || 3)" class="text-yellow-500">★</span>
                            <span v-else class="text-gray-300">★</span>
                          </span>
                        </div>
                      </div>
                      <!-- 新增：预计学习时间 -->
                      <div class="text-xs text-gray-500">
                        预计学习时间：{{ course.estimatedHours || '40' }}小时
                      </div>
                    </div>
                  </template>
                  <div v-else class="text-center text-gray-500 py-4">
                    本学期暂无推荐课程
                  </div>
                </div>

                <!-- 证书模块 -->
                <div>
                  <h5 class="font-semibold mb-2">推荐证书</h5>
                  <template v-if="semester.certificates && semester.certificates.length > 0">
                    <div 
                      v-for="cert in semester.certificates" 
                      :key="cert.name" 
                      class="bg-white p-3 rounded mb-2 shadow-sm"
                    >
                      <div class="flex justify-between items-center mb-1">
                        <span class="font-medium">{{ cert.name }}</span>
                        <span class="text-sm text-gray-600">
                          {{ cert.semester }}
                        </span>
                      </div>
                      <!-- 新增：证书价值 -->
                      <div class="text-xs text-gray-500 mb-1">
                        行业认可度：
                        <span class="text-green-600 font-medium">{{ cert.recognition || '高' }}</span>
                      </div>
                      <!-- 新增：考试费用 -->
                      <div class="text-xs text-gray-500">
                        预计费用：{{ cert.cost || '¥2,000' }}
                      </div>
                    </div>
                  </template>
                  <div v-else class="text-center text-gray-500 py-4">
                    本学期暂无推荐证书
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 新增：职业发展评估 -->
            <div class="mb-6 p-4 bg-green-50 rounded-lg">
              <h4 class="text-lg font-medium mb-3 text-green-800">职业发展评估</h4>
              <div class="space-y-3">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="bg-white p-3 rounded shadow-sm">
                    <h5 class="font-semibold text-sm text-gray-700 mb-2">规划完成后预期能力</h5>
                    <ul class="list-disc list-inside text-sm text-gray-600 space-y-1">
                      <li>掌握{{ personalizedPlan.targetCareer }}核心技术栈</li>
                      <li>具备独立开发项目的能力</li>
                      <li>能够解决复杂技术问题</li>
                    </ul>
                  </div>
                  <div class="bg-white p-3 rounded shadow-sm">
                    <h5 class="font-semibold text-sm text-gray-700 mb-2">就业市场分析</h5>
                    <p class="text-sm text-gray-600">
                      当前{{ personalizedPlan.targetCareer }}人才需求旺盛，完成规划后预计薪资可达15K-25K，就业前景良好。
                    </p>
                  </div>
                </div>
                <div class="bg-white p-3 rounded shadow-sm">
                  <h5 class="font-semibold text-sm text-gray-700 mb-2">后续职业发展建议</h5>
                  <p class="text-sm text-gray-600">
                    完成基础阶段后，可向{{ personalizedPlan.targetCareer }}架构师方向发展，或转向管理岗位如技术主管、项目经理等。
                  </p>
                </div>
              </div>
            </div>
          </div>
        </template>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { 
  Target, 
  Compass, 
  BookOpen, 
  Award, 
  Star, 
  CheckCircle
} from 'lucide-vue-next';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import axios from 'axios';

// 预设职业方向列表
const careerDirections = ref([
  { id: 1, title: '前端开发工程师', description: '专注于Web前端开发技术' },
  { id: 2, title: '后端开发工程师', description: 'Java企业级应用开发' },
  { id: 3, title: 'Python开发工程师', description: 'Python应用开发和数据分析' },
  { id: 4, title: '全栈开发工程师', description: '前后端全栈开发技术' },
  { id: 5, title: '数据工程师', description: '大数据处理和分析' },
  { id: 6, title: 'DevOps工程师', description: '开发运维一体化' }
]);

// 兴趣领域列表
const interestAreas = ref([
  { id: 1, name: '网站开发' },
  { id: 2, name: '移动应用' },
  { id: 3, name: '数据分析' },
  { id: 4, name: '云计算' },
  { id: 5, name: '人工智能' },
  { id: 6, name: '信息安全' },
  { id: 7, name: '游戏开发' },
  { id: 8, name: '企业应用' }
]);

// 新增字段
const planDuration = ref('medium');
const skillLevel = ref('beginner');
const selectedInterests = ref([]);
const weeklyStudyHours = ref('medium');

// 状态管理
const selectedCareer = ref<number | null>(null);
const loading = ref(false);
const error = ref('');
const personalizedPlan = ref(null);

// 计算属性 - 当前选择的职业对象
const selectedCareerObject = computed(() => {
  if (!selectedCareer.value) return null;
  return careerDirections.value.find(career => career.id === selectedCareer.value) || null;
});

// 页面加载时自动选择职业方向
onMounted(() => {
  console.log('[页面加载] 组件已挂载');
  if (careerDirections.value.length > 0) {
    console.log('[页面加载] 自动选择第一个职业方向');
    selectedCareer.value = careerDirections.value[0].id;
    console.log('[页面加载] 选择的职业ID:', selectedCareer.value);
  }
  
  // 获取职业方向列表
  fetchCareerDirections();
});

// 获取职业方向列表
const fetchCareerDirections = async () => {
  try {
    console.log('[API请求] 获取职业方向列表');
    const response = await axios.get('http://localhost:8080/api/career-planning/directions');
    if (response.data && Array.isArray(response.data)) {
      careerDirections.value = response.data;
      console.log('[API请求] 成功获取职业方向列表:', response.data);
      
      if (selectedCareer.value && !careerDirections.value.some(c => c.id === selectedCareer.value)) {
        selectedCareer.value = careerDirections.value[0]?.id || null;
      }
    }
  } catch (err) {
    console.error('[API请求] 获取职业方向列表失败，使用默认数据:', err);
  }
};

// 处理职业方向选择变化
const onCareerChange = (event) => {
  const value = event.target ? event.target.value : event;
  console.log('[UI事件] 职业选择变更为:', value, '类型:', typeof value);
  
  const numValue = typeof value === 'string' ? parseInt(value, 10) : value;
  console.log('[UI事件] 转换后值:', numValue, '类型:', typeof numValue);
  
  selectedCareer.value = numValue;
  console.log('[UI事件] 状态已更新:', selectedCareer.value);
  error.value = '';
};

// 生成按钮点击 - 发起后台请求
const generatePlanWithBackendRequest = async () => {
  console.log('[生成按钮] 按钮点击事件触发');
  
  if (!selectedCareer.value) {
    console.warn('[生成按钮] 未选择职业方向');
    error.value = '请先选择职业方向';
    return;
  }
  
  console.log('[生成按钮] 开始生成规划，选择的职业ID:', selectedCareer.value);
  loading.value = true;
  error.value = '';
  
  try {
    // 准备请求参数 - 包含新增字段
    const requestData = {
      selectedCareer: selectedCareer.value,
      planDuration: planDuration.value,
      skillLevel: skillLevel.value,
      interests: selectedInterests.value,
      weeklyStudyHours: weeklyStudyHours.value
    };
    
    console.log('[API请求] 发送生成规划请求，参数:', requestData);
    
    // 尝试发起后台请求
    let response;
    try {
      response = await axios.post('http://localhost:8080/api/career-planning/plan', requestData);
      console.log('[API请求] 使用plan端点成功:', response.data);
    } catch (primaryError) {
      console.log('[API请求] plan端点失败，尝试备用端点:', primaryError);
      
      try {
        response = await axios.post('http://localhost:8080/api/career-planning/generate', {
          ...requestData,
          careerId: selectedCareer.value
        });
        console.log('[API请求] 使用generate端点成功:', response.data);
      } catch (secondaryError) {
        console.log('[API请求] generate端点失败，尝试public端点:', secondaryError);
        
        response = await axios.post('http://localhost:8080/api/public/career-planning/plan', requestData);
        console.log('[API请求] 使用public端点成功:', response.data);
      }
    }
    
    // 处理响应数据
    if (response && response.data) {
      personalizedPlan.value = response.data;
      console.log('[生成按钮] 请求成功，获取到规划数据:', response.data);
    } else {
      throw new Error('获取到的数据无效');
    }
  } catch (err) {
    console.error('[生成按钮] 所有API请求失败，使用本地模拟数据:', err);
    // 所有API请求失败，回退到本地模拟数据
    const mockData = generateMockPlan(selectedCareer.value);
    personalizedPlan.value = mockData;
    console.log('[生成按钮] 使用模拟数据:', mockData);
  } finally {
    loading.value = false;
    console.log('[生成按钮] 请求处理完成');
  }
};

// 更新技能状态
const updateSkillStatus = async (semesterIndex: number, skillIndex: number, newStatus: string) => {
  console.log(`[updateSkillStatus] 更新技能: 学期${semesterIndex}, 技能${skillIndex}, 新状态:${newStatus}`);
  
  // 本地更新
  if (personalizedPlan.value?.semesters) {
    const semester = personalizedPlan.value.semesters[semesterIndex];
    if (semester?.skills) {
      semester.skills[skillIndex].status = newStatus;
      console.log('[updateSkillStatus] 本地更新成功');
      
      // 尝试发送更新到后端
      try {
        console.log('[API请求] 发送技能状态更新');
        await axios.patch('http://localhost:8080/api/career-planning/plan/skills', {
          semesterIndex,
          skillIndex,
          newStatus
        });
        console.log('[API请求] 技能状态更新成功');
      } catch (err) {
        console.error('[API请求] 技能状态更新失败:', err);
      }
    }
  }
};

// 生成模拟数据 - 考虑新增的个性化字段
const generateMockPlan = (careerId: number) => {
  console.log('[generateMockPlan] 生成模拟数据，职业ID:', careerId);
  
  const career = careerDirections.value.find(c => c.id === careerId);
  const careerTitle = career ? career.title : '软件工程师';
  
  // 根据技能水平调整内容
  const difficultyLevel = skillLevel.value === 'beginner' ? '基础' : 
                          skillLevel.value === 'intermediate' ? '进阶' : '高级';
  
  // 根据规划时长调整
  const planYears = planDuration.value === 'short' ? '1' : 
                    planDuration.value === 'medium' ? '2-3' : '4-5';
  
  // 根据学习时间设置内容密度
  const contentDensity = weeklyStudyHours.value === 'low' ? '基础' : 
                         weeklyStudyHours.value === 'medium' ? '标准' : '密集';
  
  // 技能名称和目标
  let skill1, skill2, skill3;
  let course1, course2;
  let cert;
  
  if (careerId === 1) { // 前端
    skill1 = { 
      name: 'HTML/CSS', 
      semesterGoal: `掌握${difficultyLevel}HTML5和CSS3技术`, 
      status: '进行中',
      learningResources: '推荐课程：《现代HTML与CSS实战》、MDN Web文档'
    };
    skill2 = { 
      name: 'JavaScript', 
      semesterGoal: `掌握${difficultyLevel}JavaScript编程与DOM操作`, 
      status: '未开始',
      learningResources: '推荐课程：《JavaScript高级程序设计》、JavaScript.info'
    };
    skill3 = { 
      name: '前端框架', 
      semesterGoal: `学习${difficultyLevel}React/Vue框架开发`, 
      status: '未开始',
      learningResources: '推荐课程：React官方文档、Vue.js实战'
    };
    course1 = { 
      name: 'Web前端开发基础', 
      semester: '大二上',
      difficulty: skillLevel.value === 'beginner' ? 2 : skillLevel.value === 'intermediate' ? 3 : 4,
      estimatedHours: weeklyStudyHours.value === 'low' ? '30' : weeklyStudyHours.value === 'medium' ? '45' : '60'
    };
    course2 = { 
      name: 'JavaScript编程', 
      semester: '大二下',
      difficulty: skillLevel.value === 'beginner' ? 3 : skillLevel.value === 'intermediate' ? 4 : 5,
      estimatedHours: weeklyStudyHours.value === 'low' ? '40' : weeklyStudyHours.value === 'medium' ? '60' : '80'
    };
    cert = { 
      name: '前端开发工程师认证', 
      semester: '大三上',
      recognition: skillLevel.value === 'beginner' ? '中' : '高',
      cost: skillLevel.value === 'beginner' ? '¥1,500' : '¥2,800'
    };
  } else if (careerId === 2) { // Java后端
    skill1 = { 
      name: 'Java基础', 
      semesterGoal: `掌握${difficultyLevel}Java核心语法和面向对象编程`, 
      status: '进行中',
      learningResources: '推荐课程：《Java核心技术》、Java官方教程'
    };
    skill2 = { 
      name: 'Spring框架', 
      semesterGoal: `学习${difficultyLevel}Spring Boot开发与应用`, 
      status: '未开始',
      learningResources: '推荐课程：Spring官方文档、《Spring实战》'
    };
    skill3 = { 
      name: '数据库设计', 
      semesterGoal: `掌握${difficultyLevel}SQL和数据库优化技术`, 
      status: '未开始',
      learningResources: '推荐课程：《SQL必知必会》、《高性能MySQL》'
    };
    course1 = { 
      name: 'Java程序设计', 
      semester: '大二上',
      difficulty: skillLevel.value === 'beginner' ? 3 : skillLevel.value === 'intermediate' ? 4 : 5,
      estimatedHours: weeklyStudyHours.value === 'low' ? '45' : weeklyStudyHours.value === 'medium' ? '60' : '80'
    };
    course2 = { 
      name: 'Spring框架入门', 
      semester: '大二下',
      difficulty: skillLevel.value === 'beginner' ? 3 : skillLevel.value === 'intermediate' ? 4 : 5,
      estimatedHours: weeklyStudyHours.value === 'low' ? '50' : weeklyStudyHours.value === 'medium' ? '70' : '90'
    };
    cert = { 
      name: 'Java工程师认证', 
      semester: '大三上',
      recognition: skillLevel.value === 'beginner' ? '中' : '高',
      cost: skillLevel.value === 'beginner' ? '¥2,000' : '¥3,500'
    };
  } else { // 其他职业
    skill1 = { 
      name: '编程基础', 
      semesterGoal: `掌握${difficultyLevel}编程基本概念与实践`, 
      status: '进行中',
      learningResources: '推荐课程：《编程导论》、《算法入门》'
    };
    skill2 = { 
      name: '算法与数据结构', 
      semesterGoal: `学习${difficultyLevel}算法设计与优化技术`, 
      status: '未开始',
      learningResources: '推荐课程：《算法导论》、LeetCode题库'
    };
    skill3 = { 
      name: '专业领域技能', 
      semesterGoal: `掌握${difficultyLevel}专业技术与应用`, 
      status: '未开始',
      learningResources: '推荐课程：领域专业书籍、实践项目'
    };
    course1 = { 
      name: '程序设计基础', 
      semester: '大二上',
      difficulty: skillLevel.value === 'beginner' ? 2 : skillLevel.value === 'intermediate' ? 3 : 4,
      estimatedHours: weeklyStudyHours.value === 'low' ? '40' : weeklyStudyHours.value === 'medium' ? '55' : '70'
    };
    course2 = { 
      name: '数据结构与算法', 
      semester: '大二下',
      difficulty: skillLevel.value === 'beginner' ? 3 : skillLevel.value === 'intermediate' ? 4 : 5,
      estimatedHours: weeklyStudyHours.value === 'low' ? '45' : weeklyStudyHours.value === 'medium' ? '65' : '85'
    };
    cert = { 
      name: '软件开发工程师认证', 
      semester: '大三上',
      recognition: skillLevel.value === 'beginner' ? '中' : '高',
      cost: skillLevel.value === 'beginner' ? '¥1,800' : '¥3,000'
    };
  }
  
  // 构建包含新增字段的规划数据
  return {
    targetCareer: careerTitle,
    // 新增字段
    careerPath: `初级${careerTitle} → 中级${careerTitle} → 高级${careerTitle} → 技术专家/架构师`,
    estimatedTime: `${planYears}年`,
    corePower: careerTitle.includes('前端') ? 'UI/UX设计能力、交互设计能力、前端框架精通' : 
               careerTitle.includes('后端') ? '系统架构设计、数据库优化、高并发处理' : 
               '全栈技术、项目管理、问题解决能力',
    learningIntensity: contentDensity,
    skillLevel: difficultyLevel,
    
    semesters: [
      {
        semester: '大二上',
        skills: [skill1],
        courses: [course1],
        certificates: []
      },
      {
        semester: '大二下',
        skills: [skill2],
        courses: [course2],
        certificates: []
      },
      {
        semester: '大三上',
        skills: [skill3],
        courses: [],
        certificates: [cert]
      }
    ]
  };
};
</script>
EOF

# 创建启动脚本
cat > run.sh << 'EOF'
#!/bin/bash

# 设置环境变量
export QIANWEN_API_KEY="your_api_key_here"

# 编译项目
echo "编译项目..."
./mvnw clean package -DskipTests

# 运行应用
echo "启动应用..."
java -jar target/career-planning-platform-1.0.0.jar
EOF

# 添加执行权限
chmod +x run.sh

# 创建测试运行脚本
cat > run-tests.sh << 'EOF'
#!/bin/bash

# 设置环境变量
export QIANWEN_API_KEY="your_api_key_here"

# 运行测试
echo "运行测试..."
./mvnw test
EOF

# 添加执行权限
chmod +x run-tests.sh

echo -e "${GREEN}文件创建完成!${NC}"
echo -e "${YELLOW}请执行以下步骤:${NC}"
echo "1. 在run.sh和run-tests.sh中设置您的通义千问API密钥"
echo "2. 运行 ./run.sh 启动应用程序"
echo "3. 访问 http://localhost:8080 查看应用"
echo "4. 运行 ./run-tests.sh 执行测试"
        