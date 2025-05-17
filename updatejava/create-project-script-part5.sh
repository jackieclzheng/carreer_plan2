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
'

# 36. 认证控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/AuthController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.config.JwtTokenProvider;
import com.university.careerplanning.dto.AuthRequest;
import com.university.careerplanning.dto.AuthResponse;
import com.university.careerplanning.dto.RegisterRequest;
import com.university.careerplanning.model.User;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody AuthRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUsername(),
                        loginRequest.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtTokenProvider.generateToken((UserDetails) authentication.getPrincipal());

        User user = userService.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        return ResponseEntity.ok(new AuthResponse(jwt, user.getId(), user.getUsername(), user.getEmail()));
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
        User user = userService.registerNewUser(registerRequest);
        return ResponseEntity.ok("用户注册成功");
    }
}
'

# 37. 用户控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/UserController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.model.User;
import com.university.careerplanning.service.UserService;
import com.university.careerplanning.dto.RegisterRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
        User registeredUser = userService.registerNewUser(registerRequest);
        return ResponseEntity.ok(registeredUser);
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile() {
        // 这里应该从安全上下文获取当前用户
        // 实际应用中需要实现更复杂的用户获取逻辑
        return ResponseEntity.ok("用户资料");
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(@RequestBody User user) {
        User updatedUser = userService.updateUser(user);
        return ResponseEntity.ok(updatedUser);
    }
}
'

# 38. 证书控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/CertificateController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CertificateDTO;
import com.university.careerplanning.model.Certificate;
import com.university.careerplanning.service.CertificateService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/certificates")
public class CertificateController {

    @Autowired
    private CertificateService certificateService;
    
    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<CertificateDTO>> getCertificates(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Certificate> certificates = certificateService.getCertificatesByUserId(userId);
        
        List<CertificateDTO> certificateDTOs = certificates.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(certificateDTOs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CertificateDTO> getCertificateById(@PathVariable Long id) {
        Certificate certificate = certificateService.getCertificateById(id);
        return ResponseEntity.ok(convertToDTO(certificate));
    }

    @PostMapping
    public ResponseEntity<CertificateDTO> createCertificate(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CertificateDTO certificateDTO) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        Certificate certificate = convertToEntity(certificateDTO);
        Certificate savedCertificate = certificateService.createCertificate(userId, certificate);
        
        return ResponseEntity.ok(convertToDTO(savedCertificate));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CertificateDTO> updateCertificate(
            @PathVariable Long id,
            @Valid @RequestBody CertificateDTO certificateDTO) {
        
        Certificate certificate = convertToEntity(certificateDTO);
        Certificate updatedCertificate = certificateService.updateCertificate(id, certificate);
        
        return ResponseEntity.ok(convertToDTO(updatedCertificate));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCertificate(@PathVariable Long id) {
        certificateService.deleteCertificate(id);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/upload")
    public ResponseEntity<?> uploadCertificateFile(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) throws IOException {
        
        // 这里应该实现文件存储逻辑，如将文件保存到文件系统或云存储
        // 简化示例：只返回成功消息和模拟的文件URL
        String fileUrl = "/uploads/certificates/" + id + "_" + file.getOriginalFilename();
        
        return ResponseEntity.ok(new FileUploadResponse(fileUrl));
    }
    
    // 辅助方法：将实体转换为DTO
    private CertificateDTO convertToDTO(Certificate certificate) {
        CertificateDTO dto = new CertificateDTO();
        dto.setId(certificate.getId());
        dto.setName(certificate.getName());
        dto.setIssuer(certificate.getIssuer());
        
        // 格式化日期为字符串
        if (certificate.getIssueDate() != null) {
            dto.setDate(certificate.getIssueDate().format(DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        // 设置类型（在DTO中添加type字段）
        dto.setType(certificate.getDescription() != null ? certificate.getDescription() : "专业认证");
        
        // 文件URL可能需要从其他地方获取
        dto.setFileUrl(null);
        
        return dto;
    }
    
    // 辅助方法：将DTO转换为实体
    private Certificate convertToEntity(CertificateDTO dto) {
        Certificate certificate = new Certificate();
        
        if (dto.getId() != null) {
            certificate.setId(dto.getId());
        }
        
        certificate.setName(dto.getName());
        certificate.setIssuer(dto.getIssuer());
        
        // 解析日期字符串
        if (dto.getDate() != null && !dto.getDate().isEmpty()) {
            certificate.setIssueDate(LocalDate.parse(dto.getDate(), DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        // 将type字段存储到description
        if (dto.getType() != null) {
            certificate.setDescription(dto.getType());
        }
        
        return certificate;
    }
    
    // 文件上传响应类
    public static class FileUploadResponse {
        private String fileUrl;
        
        public FileUploadResponse(String fileUrl) {
            this.fileUrl = fileUrl;
        }
        
        public String getFileUrl() {
            return fileUrl;
        }
    }
}
'

# 39. 课程控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/CourseController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CourseDTO;
import com.university.careerplanning.dto.ScoreUpdateRequest;
import com.university.careerplanning.model.Course;
import com.university.careerplanning.service.CourseService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/courses")
public class CourseController {

    @Autowired
    private CourseService courseService;
    
    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<CourseDTO>> getCourses(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Course> courses = courseService.getCoursesByUserId(userId);
        
        List<CourseDTO> courseDTOs = courses.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(courseDTOs);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getCourseStats(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Course> courses = courseService.getCoursesByUserId(userId);
        double gpa = courseService.calculateGPA(userId);
        
        int totalCredits = courses.stream().mapToInt(Course::getCredits).sum();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCourses", courses.size());
        stats.put("totalCredits", totalCredits);
        stats.put("gpa", gpa);
        
        return ResponseEntity.ok(stats);
    }

    @PostMapping
    public ResponseEntity<CourseDTO> createCourse(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CourseDTO courseDTO) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        Course course = convertToEntity(courseDTO);
        Course savedCourse = courseService.createCourse(userId, course);
        
        return ResponseEntity.ok(convertToDTO(savedCourse));
    }

    @PatchMapping("/{id}/score")
    public ResponseEntity<CourseDTO> updateCourseScore(
            @PathVariable Long id,
            @Valid @RequestBody ScoreUpdateRequest request) {
        
        Course updatedCourse = courseService.updateCourseScore(id, request.getScore());
        return ResponseEntity.ok(convertToDTO(updatedCourse));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCourse(@PathVariable Long id) {
        courseService.deleteCourse(id);
        return ResponseEntity.ok().build();
    }
    
    // 辅助方法：将实体转换为DTO
    private CourseDTO convertToDTO(Course course) {
        CourseDTO dto = new CourseDTO();
        dto.setId(course.getId());
        dto.setName(course.getName());
        dto.setSemester(course.getSemester());
        dto.setScore(course.getScore());
        dto.setCredits(course.getCredits());
        
        return dto;
    }
    
    // 辅助方法：将DTO转换为实体
    private Course convertToEntity(CourseDTO dto) {
        Course course = new Course();
        
        if (dto.getId() != null) {
            course.setId(dto.getId());
        }
        
        course.setName(dto.getName());
        course.setSemester(dto.getSemester());
        course.setScore(dto.getScore());
        course.setCredits(dto.getCredits());
        
        return course;
    }
}
'
