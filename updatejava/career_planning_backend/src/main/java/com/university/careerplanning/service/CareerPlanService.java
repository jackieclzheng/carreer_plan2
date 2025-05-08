package com.university.careerplanning.service;

import com.university.careerplanning.dto.*;
import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.CareerPlan;
import com.university.careerplanning.model.Course;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.CareerPlanRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Service
public class CareerPlanService {

    @Autowired
    private CareerPlanRepository careerPlanRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CourseService courseService;

    // 预定义职业方向数据
    private List<CareerDirectionDTO> predefinedDirections = Arrays.asList(
        createFrontendDirection(),
        createBackendDirection()
    );
    
    // 获取所有预定义职业方向
    public List<CareerDirectionDTO> getAllCareerDirections() {
        return predefinedDirections;
    }
    
    // 获取用户的个性化职业规划
    public CareerPlanDTO getPersonalizedPlan(Long userId) {
        // 从数据库中查找用户的职业规划
        Optional<CareerPlan> existingPlan = careerPlanRepository.findByUserIdAndStatus(userId, "active");
        
        if (existingPlan.isPresent()) {
            // 从存储的JSON恢复职业规划数据
            return deserializePlan(existingPlan.get());
        }
        
        // 如果没有现有规划，返回null
        return null;
    }
    
    // 生成个性化职业规划
    @Transactional
    public CareerPlanDTO generatePersonalizedPlan(Long userId, Integer selectedCareerIndex) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
        
        // 获取选定的职业方向
        if (selectedCareerIndex == null || selectedCareerIndex < 0 || selectedCareerIndex >= predefinedDirections.size()) {
            throw new IllegalArgumentException("无效的职业方向选择");
        }
        
        CareerDirectionDTO selectedCareer = predefinedDirections.get(selectedCareerIndex);
        
        // 创建职业规划DTO
        CareerPlanDTO planDTO = new CareerPlanDTO();
        planDTO.setTargetCareer(selectedCareer.getTitle());
        
        // 创建学期规划
        List<SemesterPlanDTO> semesters = new ArrayList<>();
        
        // 大二上学期
        SemesterPlanDTO semester1 = new SemesterPlanDTO();
        semester1.setSemester("大二上");
        
        List<SkillSemesterGoalDTO> skills1 = new ArrayList<>();
        if (!selectedCareer.getRecommendedSkills().isEmpty()) {
            SkillSemesterGoalDTO skill = new SkillSemesterGoalDTO();
            skill.setName(selectedCareer.getRecommendedSkills().get(0).getName());
            skill.setSemesterGoal(selectedCareer.getRecommendedSkills().get(0).getSemesterGoal());
            skill.setStatus("进行中");
            skills1.add(skill);
        }
        semester1.setSkills(skills1);
        
        List<SemesterCourseDTO> courses1 = new ArrayList<>();
        for (SemesterCourseDTO course : selectedCareer.getRecommendedCourses()) {
            if ("大二上".equals(course.getSemester())) {
                courses1.add(course);
            }
        }
        semester1.setCourses(courses1);
        semester1.setCertificates(new ArrayList<>());
        
        // 大二下学期
        SemesterPlanDTO semester2 = new SemesterPlanDTO();
        semester2.setSemester("大二下");
        
        List<SkillSemesterGoalDTO> skills2 = new ArrayList<>();
        if (selectedCareer.getRecommendedSkills().size() > 1) {
            SkillSemesterGoalDTO skill = new SkillSemesterGoalDTO();
            skill.setName(selectedCareer.getRecommendedSkills().get(1).getName());
            skill.setSemesterGoal(selectedCareer.getRecommendedSkills().get(1).getSemesterGoal());
            skill.setStatus("未开始");
            skills2.add(skill);
        }
        semester2.setSkills(skills2);
        
        List<SemesterCourseDTO> courses2 = new ArrayList<>();
        for (SemesterCourseDTO course : selectedCareer.getRecommendedCourses()) {
            if ("大二下".equals(course.getSemester())) {
                courses2.add(course);
            }
        }
        semester2.setCourses(courses2);
        semester2.setCertificates(new ArrayList<>());
        
        // 大三上学期
        SemesterPlanDTO semester3 = new SemesterPlanDTO();
        semester3.setSemester("大三上");
        
        List<SkillSemesterGoalDTO> skills3 = new ArrayList<>();
        if (selectedCareer.getRecommendedSkills().size() > 2) {
            SkillSemesterGoalDTO skill = new SkillSemesterGoalDTO();
            skill.setName(selectedCareer.getRecommendedSkills().get(2).getName());
            skill.setSemesterGoal(selectedCareer.getRecommendedSkills().get(2).getSemesterGoal());
            skill.setStatus("未开始");
            skills3.add(skill);
        }
        semester3.setSkills(skills3);
        
        semester3.setCourses(new ArrayList<>());
        semester3.setCertificates(selectedCareer.getRecommendedCertificates());
        
        semesters.add(semester1);
        semesters.add(semester2);
        semesters.add(semester3);
        
        planDTO.setSemesters(semesters);
        
        // 存储到数据库
        // 首先将所有现有规划标记为非激活
        careerPlanRepository.deactivateAllUserPlans(userId);
        
        // 创建新的职业规划记录
        CareerPlan plan = new CareerPlan();
        plan.setUser(user);
        plan.setCareerDirection(selectedCareer.getTitle());
        plan.setStatus("active");
        
        // 序列化规划数据为JSON并存储
        plan.setGoals(serializePlan(planDTO));
        
        careerPlanRepository.save(plan);
        
        return planDTO;
    }
    
    // 更新技能状态
    @Transactional
    public CareerPlanDTO updateSkillStatus(Long userId, int semesterIndex, int skillIndex, String newStatus) {
        CareerPlanDTO plan = getPersonalizedPlan(userId);
        
        if (plan == null) {
            throw new ResourceNotFoundException("未找到职业规划");
        }
        
        if (semesterIndex < 0 || semesterIndex >= plan.getSemesters().size()) {
            throw new IllegalArgumentException("无效的学期索引");
        }
        
        SemesterPlanDTO semester = plan.getSemesters().get(semesterIndex);
        
        if (skillIndex < 0 || skillIndex >= semester.getSkills().size()) {
            throw new IllegalArgumentException("无效的技能索引");
        }
        
        // 更新技能状态
        semester.getSkills().get(skillIndex).setStatus(newStatus);
        
        // 更新数据库中的规划
        CareerPlan careerPlan = careerPlanRepository.findByUserIdAndStatus(userId, "active")
                .orElseThrow(() -> new ResourceNotFoundException("未找到职业规划"));
                
        careerPlan.setGoals(serializePlan(plan));
        careerPlanRepository.save(careerPlan);
        
        return plan;
    }
    
    // 辅助方法：创建前端开发工程师职业方向
    private CareerDirectionDTO createFrontendDirection() {
        CareerDirectionDTO direction = new CareerDirectionDTO();
        direction.setId(1);
        direction.setTitle("前端开发工程师");
        
        // 推荐技能
        List<SkillSemesterGoalDTO> skills = new ArrayList<>();
        
        SkillSemesterGoalDTO skill1 = new SkillSemesterGoalDTO();
        skill1.setName("HTML/CSS");
        skill1.setSemesterGoal("熟练掌握");
        skills.add(skill1);
        
        SkillSemesterGoalDTO skill2 = new SkillSemesterGoalDTO();
        skill2.setName("JavaScript");
        skill2.setSemesterGoal("深入学习");
        skills.add(skill2);
        
        SkillSemesterGoalDTO skill3 = new SkillSemesterGoalDTO();
        skill3.setName("React");
        skill3.setSemesterGoal("项目实践");
        skills.add(skill3);
        
        direction.setRecommendedSkills(skills);
        
        // 推荐课程
        List<SemesterCourseDTO> courses = new ArrayList<>();
        
        SemesterCourseDTO course1 = new SemesterCourseDTO();
        course1.setName("Web前端开发");
        course1.setSemester("大二上");
        courses.add(course1);
        
        SemesterCourseDTO course2 = new SemesterCourseDTO();
        course2.setName("前端框架");
        course2.setSemester("大二下");
        courses.add(course2);
        
        direction.setRecommendedCourses(courses);
        
        // 推荐证书
        List<SemesterCertificateDTO> certificates = new ArrayList<>();
        
        SemesterCertificateDTO cert1 = new SemesterCertificateDTO();
        cert1.setName("Web前端开发证书");
        cert1.setSemester("大三上");
        certificates.add(cert1);
        
        direction.setRecommendedCertificates(certificates);
        
        return direction;
    }
    
    // 辅助方法：创建后端开发工程师职业方向
    private CareerDirectionDTO createBackendDirection() {
        CareerDirectionDTO direction = new CareerDirectionDTO();
        direction.setId(2);
        direction.setTitle("后端开发工程师");
        
        // 推荐技能
        List<SkillSemesterGoalDTO> skills = new ArrayList<>();
        
        SkillSemesterGoalDTO skill1 = new SkillSemesterGoalDTO();
        skill1.setName("Java");
        skill1.setSemesterGoal("深入学习");
        skills.add(skill1);
        
        SkillSemesterGoalDTO skill2 = new SkillSemesterGoalDTO();
        skill2.setName("Spring Boot");
        skill2.setSemesterGoal("项目实践");
        skills.add(skill2);
        
        SkillSemesterGoalDTO skill3 = new SkillSemesterGoalDTO();
        skill3.setName("数据库");
        skill3.setSemesterGoal("精通");
        skills.add(skill3);
        
        direction.setRecommendedSkills(skills);
        
        // 推荐课程
        List<SemesterCourseDTO> courses = new ArrayList<>();
        
        SemesterCourseDTO course1 = new SemesterCourseDTO();
        course1.setName("Java程序设计");
        course1.setSemester("大二上");
        courses.add(course1);
        
        SemesterCourseDTO course2 = new SemesterCourseDTO();
        course2.setName("数据库系统");
        course2.setSemester("大二下");
        courses.add(course2);
        
        direction.setRecommendedCourses(courses);
        
        // 推荐证书
        List<SemesterCertificateDTO> certificates = new ArrayList<>();
        
        SemesterCertificateDTO cert1 = new SemesterCertificateDTO();
        cert1.setName("Java开发认证");
        cert1.setSemester("大三上");
        certificates.add(cert1);
        
        direction.setRecommendedCertificates(certificates);
        
        return direction;
    }
    
    // 辅助方法：序列化职业规划为JSON
    private String serializePlan(CareerPlanDTO plan) {
        // 在实际实现中应该使用Jackson或Gson等库
        // 简化处理，这里只返回一个占位符
        return "{\"planData\": \"serialized plan data\"}";
    }
    
    // 辅助方法：从JSON反序列化职业规划
    private CareerPlanDTO deserializePlan(CareerPlan plan) {
        // 在实际实现中应该使用Jackson或Gson等库解析JSON
        // 简化处理，这里使用预定义规划作为示例
        if (plan.getCareerDirection().contains("前端")) {
            CareerDirectionDTO direction = predefinedDirections.get(0);
            return generatePersonalizedPlan(plan.getUser().getId(), 0);
        } else {
            CareerDirectionDTO direction = predefinedDirections.get(1);
            return generatePersonalizedPlan(plan.getUser().getId(), 1);
        }
    }
}