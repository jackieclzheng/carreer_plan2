# 17. 课程仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/CourseRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Course;
import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByUser(User user);
    List<Course> findByUserAndSemester(User user, String semester);
}
'

# 18. 任务仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/TaskRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Task;
import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByUser(User user);
    List<Task> findByUserAndStatus(User user, String status);
}
'

# 19. 职业仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/CareerRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Career;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CareerRepository extends JpaRepository<Career, Long> {
    @Query("SELECT c FROM Career c WHERE " +
           "LOWER(c.title) LIKE LOWER(CONCAT(\'%\', :searchTerm, \'%\')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT(\'%\', :searchTerm, \'%\'))")
    Page<Career> search(@Param("searchTerm") String searchTerm, Pageable pageable);
    
    @Query(value = "SELECT c FROM Career c " +
                  "JOIN c.requiredSkills skill " +
                  "WHERE LOWER(skill) LIKE LOWER(CONCAT(\'%\', :skill, \'%\'))")
    List<Career> findByRequiredSkill(@Param("skill") String skill);
}
'

# 20. 收藏职业仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/SavedCareerRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Career;
import com.university.careerplanning.model.SavedCareer;
import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SavedCareerRepository extends JpaRepository<SavedCareer, Long> {
    List<SavedCareer> findByUser(User user);
    Optional<SavedCareer> findByUserAndCareer(User user, Career career);
    boolean existsByUserAndCareer(User user, Career career);
}
'

# 21. 注册请求DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/RegisterRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RegisterRequest {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20个字符之间")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, message = "密码长度至少6个字符")
    private String password;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "专业不能为空")
    private String major;

    @NotBlank(message = "入学年份不能为空")
    private String enrollmentYear;

    // Getters and setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getMajor() { return major; }
    public void setMajor(String major) { this.major = major; }
    public String getEnrollmentYear() { return enrollmentYear; }
    public void setEnrollmentYear(String enrollmentYear) { this.enrollmentYear = enrollmentYear; }
}
'

# 22. 认证相关DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/AuthRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;

public class AuthRequest {
    @NotBlank(message = "用户名不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;

    // Getters and setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/AuthResponse.java" '
package com.university.careerplanning.dto;

public class AuthResponse {
    private String token;
    private Long id;
    private String username;
    private String email;

    public AuthResponse(String token, Long id, String username, String email) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.email = email;
    }

    // Getters
    public String getToken() { return token; }
    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
}
'

# 23. 证书DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/CertificateDTO.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;

public class CertificateDTO {
    private Long id;
    
    @NotBlank(message = "证书名称不能为空")
    private String name;
    
    @NotBlank(message = "颁发机构不能为空")
    private String issuer;
    
    @NotBlank(message = "获取日期不能为空")
    private String date;
    
    private String type;
    
    private String fileUrl;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getIssuer() { return issuer; }
    public void setIssuer(String issuer) { this.issuer = issuer; }
    
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
}
'

# 24. 课程DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/CourseDTO.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public class CourseDTO {
    private Long id;
    
    @NotBlank(message = "课程名称不能为空")
    private String name;
    
    @NotBlank(message = "学期不能为空")
    private String semester;
    
    @Min(value = 0, message = "成绩不能小于0")
    @Max(value = 100, message = "成绩不能大于100")
    private int score;
    
    @Positive(message = "学分必须为正数")
    private int credits;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }
    
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    
    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/ScoreUpdateRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class ScoreUpdateRequest {
    @Min(value = 0, message = "成绩不能小于0")
    @Max(value = 100, message = "成绩不能大于100")
    private int score;
    
    // Getter and Setter
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
}
'

# 25. 任务DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/TaskDTO.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public class TaskDTO {
    private Long id;
    
    @NotBlank(message = "任务标题不能为空")
    private String title;
    
    private String description;
    
    @NotBlank(message = "截止日期不能为空")
    private String deadline;
    
    @NotBlank(message = "任务状态不能为空")
    private String status;
    
    @Min(value = 0, message = "进度不能小于0")
    @Max(value = 100, message = "进度不能大于100")
    private int progress;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getDeadline() { return deadline; }
    public void setDeadline(String deadline) { this.deadline = deadline; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/ProgressUpdateRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class ProgressUpdateRequest {
    @Min(value = 0, message = "进度不能小于0")
    @Max(value = 100, message = "进度不能大于100")
    private int progress;
    
    // Getter and Setter
    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/BatchStatusUpdateRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class BatchStatusUpdateRequest {
    @NotEmpty(message = "任务ID列表不能为空")
    private List<Long> ids;
    
    @NotBlank(message = "状态不能为空")
    private String status;
    
    // Getters and Setters
    public List<Long> getIds() { return ids; }
    public void setIds(List<Long> ids) { this.ids = ids; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
'

# 26. 职业DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/CareerDTO.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class CareerDTO {
    private Long id;
    private String title;
    private String description;
    private List<String> requiredSkills;
    private String averageSalary;
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public List<String> getRequiredSkills() { return requiredSkills; }
    public void setRequiredSkills(List<String> requiredSkills) { this.requiredSkills = requiredSkills; }
    
    public String getAverageSalary() { return averageSalary; }
    public void setAverageSalary(String averageSalary) { this.averageSalary = averageSalary; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SaveCareerRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotNull;

public class SaveCareerRequest {
    @NotNull(message = "职业ID不能为空")
    private Long careerId;
    
    // Getter and Setter
    public Long getCareerId() { return careerId; }
    public void setCareerId(Long careerId) { this.careerId = careerId; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SearchResponse.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class SearchResponse {
    private List<CareerDTO> careers;
    private long total;
    private int page;
    private int pageSize;
    
    // Getters and Setters
    public List<CareerDTO> getCareers() { return careers; }
    public void setCareers(List<CareerDTO> careers) { this.careers = careers; }
    
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    
    public int getPageSize() { return pageSize; }
    public void setPageSize(int pageSize) { this.pageSize = pageSize; }
}
'

# 27. 仪表盘DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/DashboardDTO.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class DashboardDTO {
    private int overallProgress;
    private String currentGoal;
    private List<KeyMetricDTO> keyMetrics;
    private List<SkillProgressDTO> skillProgress;
    private List<RecentActivityDTO> recentActivities;
    
    // Getters and Setters
    public int getOverallProgress() { return overallProgress; }
    public void setOverallProgress(int overallProgress) { this.overallProgress = overallProgress; }
    
    public String getCurrentGoal() { return currentGoal; }
    public void setCurrentGoal(String currentGoal) { this.currentGoal = currentGoal; }
    
    public List<KeyMetricDTO> getKeyMetrics() { return keyMetrics; }
    public void setKeyMetrics(List<KeyMetricDTO> keyMetrics) { this.keyMetrics = keyMetrics; }
    
    public List<SkillProgressDTO> getSkillProgress() { return skillProgress; }
    public void setSkillProgress(List<SkillProgressDTO> skillProgress) { this.skillProgress = skillProgress; }
    
    public List<RecentActivityDTO> getRecentActivities() { return recentActivities; }
    public void setRecentActivities(List<RecentActivityDTO> recentActivities) { this.recentActivities = recentActivities; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/KeyMetricDTO.java" '
package com.university.careerplanning.dto;

public class KeyMetricDTO {
    private int id;
    private String title;
    private int value;
    private int change;
    private String trend;
    
    public KeyMetricDTO() {}
    
    public KeyMetricDTO(int id, String title, int value, int change, String trend) {
        this.id = id;
        this.title = title;
        this.value = value;
        this.change = change;
        this.trend = trend;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public int getValue() { return value; }
    public void setValue(int value) { this.value = value; }
    
    public int getChange() { return change; }
    public void setChange(int change) { this.change = change; }
    
    public String getTrend() { return trend; }
    public void setTrend(String trend) { this.trend = trend; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SkillProgressDTO.java" '
package com.university.careerplanning.dto;

public class SkillProgressDTO {
    private int id;
    private String name;
    private int progress;
    
    public SkillProgressDTO() {}
    
    public SkillProgressDTO(int id, String name, int progress) {
        this.id = id;
        this.name = name;
        this.progress = progress;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/RecentActivityDTO.java" '
package com.university.careerplanning.dto;

public class RecentActivityDTO {
    private int id;
    private String title;
    private String date;
    private String type;
    
    public RecentActivityDTO() {}
    
    public RecentActivityDTO(int id, String title, String date, String type) {
        this.id = id;
        this.title = title;
        this.date = date;
        this.type = type;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/GoalUpdateRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.NotBlank;

public class GoalUpdateRequest {
    @NotBlank(message = "目标不能为空")
    private String goal;
    
    public GoalUpdateRequest() {}
    
    public GoalUpdateRequest(String goal) {
        this.goal = goal;
    }
    
    // Getter and Setter
    public String getGoal() { return goal; }
    public void setGoal(String goal) { this.goal = goal; }
}
'

# 28. 职业规划DTO
create_file "$BASE_DIR/$PACKAGE_PATH/dto/CareerDirectionDTO.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class CareerDirectionDTO {
    private int id;
    private String title;
    private List<SkillSemesterGoalDTO> recommendedSkills;
    private List<SemesterCourseDTO> recommendedCourses;
    private List<SemesterCertificateDTO> recommendedCertificates;
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public List<SkillSemesterGoalDTO> getRecommendedSkills() { return recommendedSkills; }
    public void setRecommendedSkills(List<SkillSemesterGoalDTO> recommendedSkills) { this.recommendedSkills = recommendedSkills; }
    
    public List<SemesterCourseDTO> getRecommendedCourses() { return recommendedCourses; }
    public void setRecommendedCourses(List<SemesterCourseDTO> recommendedCourses) { this.recommendedCourses = recommendedCourses; }
    
    public List<SemesterCertificateDTO> getRecommendedCertificates() { return recommendedCertificates; }
    public void setRecommendedCertificates(List<SemesterCertificateDTO> recommendedCertificates) { this.recommendedCertificates = recommendedCertificates; }
}
'
