# 32. 课程服务
create_file "$BASE_DIR/$PACKAGE_PATH/service/CourseService.java" '
package com.university.careerplanning.service;

import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.Course;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.CourseRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CourseService {

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Course> getCoursesByUserId(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        return courseRepository.findByUser(user);
    }

    public Course getCourseById(Long courseId) {
        return courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("课程不存在"));
    }

    @Transactional
    public Course createCourse(Long userId, Course course) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        course.setUser(user);
        
        return courseRepository.save(course);
    }

    @Transactional
    public Course updateCourseScore(Long courseId, int newScore) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("课程不存在"));
                
        course.setScore(newScore);
        
        return courseRepository.save(course);
    }

    @Transactional
    public void deleteCourse(Long courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("课程不存在"));
                
        courseRepository.delete(course);
    }
    
    // 计算GPA
    public double calculateGPA(Long userId) {
        List<Course> courses = getCoursesByUserId(userId);
        
        if (courses.isEmpty()) {
            return 0.0;
        }
        
        double totalCredits = 0.0;
        double totalGradePoints = 0.0;
        
        for (Course course : courses) {
            double gradePoint = getGradePoint(course.getScore());
            double coursePoints = gradePoint * course.getCredits();
            
            totalGradePoints += coursePoints;
            totalCredits += course.getCredits();
        }
        
        return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
    }
    
    // 将百分制分数转换为绩点
    private double getGradePoint(int score) {
        if (score >= 90) return 4.0;
        if (score >= 85) return 3.7;
        if (score >= 80) return 3.3;
        if (score >= 75) return 3.0;
        if (score >= 70) return 2.7;
        if (score >= 65) return 2.3;
        if (score >= 60) return 2.0;
        return 0.0;
    }
}
'

# 33. 任务服务
create_file "$BASE_DIR/$PACKAGE_PATH/service/TaskService.java" '
package com.university.careerplanning.service;

import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.Task;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.TaskRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskRepository taskRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Task> getTasksByUserId(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        return taskRepository.findByUser(user);
    }

    public Task getTaskById(Long taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("任务不存在"));
    }

    @Transactional
    public Task createTask(Long userId, Task task) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        task.setUser(user);
        
        return taskRepository.save(task);
    }

    @Transactional
    public Task updateTask(Long taskId, Task updatedTask) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("任务不存在"));
                
        // 更新字段
        if (updatedTask.getTitle() != null) {
            task.setTitle(updatedTask.getTitle());
        }
        
        if (updatedTask.getDescription() != null) {
            task.setDescription(updatedTask.getDescription());
        }
        
        if (updatedTask.getDeadline() != null) {
            task.setDeadline(updatedTask.getDeadline());
        }
        
        if (updatedTask.getStatus() != null) {
            task.setStatus(updatedTask.getStatus());
        }
        
        if (updatedTask.getProgress() >= 0) {
            task.setProgress(updatedTask.getProgress());
        }
        
        return taskRepository.save(task);
    }

    @Transactional
    public Task updateTaskProgress(Long taskId, int progress) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("任务不存在"));
                
        task.setProgress(progress);
        
        // 根据进度自动更新状态
        if (progress == 100) {
            task.setStatus("已完成");
        } else if (progress > 0) {
            task.setStatus("进行中");
        }
        
        return taskRepository.save(task);
    }

    @Transactional
    public void deleteTask(Long taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("任务不存在"));
                
        taskRepository.delete(task);
    }
    
    @Transactional
    public List<Task> updateTasksStatus(List<Long> taskIds, String status) {
        List<Task> tasks = taskRepository.findAllById(taskIds);
        
        if (tasks.isEmpty()) {
            throw new ResourceNotFoundException("未找到指定的任务");
        }
        
        tasks.forEach(task -> task.setStatus(status));
        
        return taskRepository.saveAll(tasks);
    }
}
'

# 34. 职业服务
create_file "$BASE_DIR/$PACKAGE_PATH/service/CareerService.java" '
package com.university.careerplanning.service;

import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.Career;
import com.university.careerplanning.model.SavedCareer;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.CareerRepository;
import com.university.careerplanning.repository.SavedCareerRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CareerService {

    @Autowired
    private CareerRepository careerRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private SavedCareerRepository savedCareerRepository;

    public Page<Career> searchCareers(String searchTerm, Pageable pageable) {
        return careerRepository.search(searchTerm, pageable);
    }

    public Career getCareerById(Long careerId) {
        return careerRepository.findById(careerId)
                .orElseThrow(() -> new ResourceNotFoundException("职业信息不存在"));
    }

    // 根据用户的技能和兴趣推荐职业
    public List<Career> getRecommendedCareers(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        // 这里简化处理，实际应用中应该有更复杂的推荐算法
        // 比如基于用户已完成的课程、技能测评等数据
        
        // 模拟推荐：假设根据用户专业推荐相关职业
        String major = user.getMajor();
        List<Career> allCareers = careerRepository.findAll();
        List<Career> recommendedCareers = new ArrayList<>();
        
        // 简单示例：通过专业和描述字段匹配
        for (Career career : allCareers) {
            if (career.getDescription().toLowerCase().contains(major.toLowerCase()) ||
                career.getTitle().toLowerCase().contains(major.toLowerCase())) {
                recommendedCareers.add(career);
            }
        }
        
        // 如果没有匹配，返回几个默认推荐
        if (recommendedCareers.isEmpty() && !allCareers.isEmpty()) {
            int recommendCount = Math.min(3, allCareers.size());
            recommendedCareers = allCareers.subList(0, recommendCount);
        }
        
        return recommendedCareers;
    }
    
    // 保存职业收藏
    @Transactional
    public SavedCareer saveCareer(Long userId, Long careerId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        Career career = careerRepository.findById(careerId)
                .orElseThrow(() -> new ResourceNotFoundException("职业信息不存在"));
                
        // 检查是否已收藏
        if (savedCareerRepository.existsByUserAndCareer(user, career)) {
            throw new RuntimeException("该职业已收藏");
        }
        
        SavedCareer savedCareer = new SavedCareer();
        savedCareer.setUser(user);
        savedCareer.setCareer(career);
        
        return savedCareerRepository.save(savedCareer);
    }
    
    // 取消收藏
    @Transactional
    public void unsaveCareer(Long userId, Long careerId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        Career career = careerRepository.findById(careerId)
                .orElseThrow(() -> new ResourceNotFoundException("职业信息不存在"));
                
        SavedCareer savedCareer = savedCareerRepository.findByUserAndCareer(user, career)
                .orElseThrow(() -> new ResourceNotFoundException("未找到收藏记录"));
                
        savedCareerRepository.delete(savedCareer);
    }
    
    // 获取用户收藏的职业
    public List<Career> getSavedCareers(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        List<SavedCareer> savedCareers = savedCareerRepository.findByUser(user);
        
        return savedCareers.stream()
                .map(SavedCareer::getCareer)
                .collect(Collectors.toList());
    }
}
'

# 35. 职业规划服务
create_file "$BASE_DIR/$PACKAGE_PATH/service/CareerPlanService.java" '
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
        cert1.setName("