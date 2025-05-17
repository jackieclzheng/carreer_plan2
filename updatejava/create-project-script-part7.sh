#!/bin/bash

# 设置基础目录
BASE_DIR="career_planning_backend"
PACKAGE_PATH="src/main/java/com/university/careerplanning"
RESOURCES_PATH="src/main/resources"

# 创建文件的函数
create_file() {
  local file_path="$1"
  local content="$2"
  mkdir -p "$(dirname "$file_path")"
  echo "$content" > "$file_path"
  echo "创建文件: $file_path"
}

# 创建剩余的仓库接口
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
           "LOWER(c.title) LIKE LOWER(CONCAT(''%'', :searchTerm, ''%'')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT(''%'', :searchTerm, ''%''))")
    Page<Career> search(@Param("searchTerm") String searchTerm, Pageable pageable);
    
    @Query(value = "SELECT c FROM Career c " +
                  "JOIN c.requiredSkills skill " +
                  "WHERE LOWER(skill) LIKE LOWER(CONCAT(''%'', :skill, ''%''))")
    List<Career> findByRequiredSkill(@Param("skill") String skill);
}
'

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

# 创建DTO类
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

# 创建服务类
create_file "$BASE_DIR/$PACKAGE_PATH/service/UserService.java" '
package com.university.careerplanning.service;

import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.UserRepository;
import com.university.careerplanning.dto.RegisterRequest;
import com.university.careerplanning.exception.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Transactional
    public User registerNewUser(RegisterRequest request) {
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }

        // 检查邮箱是否已存在
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("邮箱已被注册");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setMajor(request.getMajor());
        
        // 根据入学年份设置入学日期
        user.setEnrollmentDate(LocalDate.of(
            Integer.parseInt(request.getEnrollmentYear()), 9, 1)
        );

        return userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/service/CustomUserDetailsService.java" '
package com.university.careerplanning.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.UserRepository;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + username));

        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
        );
    }
}
'

# 创建控制器类
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

# 添加pom.xml文件
create_file "$BASE_DIR/pom.xml" '
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.6</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.university</groupId>
    <artifactId>career-planning</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>career-planning</name>
    <description>Career Planning Platform for University Students</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- H2数据库，用于开发/测试 -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- JWT依赖 -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- 测试依赖 -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
'

# 添加数据初始化脚本
create_file "$BASE_DIR/$RESOURCES_PATH/data.sql" '
-- 初始化测试数据

-- 用户数据
INSERT INTO users (username, password, email, major, enrollment_date) 
VALUES (''admin'', ''$2a$10$XFE7nxHkCGGy5pMz8wXG8.6oWWJYhzBPVKbWbO6r5xqwTwBFbQHJu'', ''admin@example.com'', ''计算机科学'', ''2023-09-01'');

-- 职业数据
INSERT INTO careers (title, description, average_salary)
VALUES (''前端开发工程师'', ''负责网站和web应用程序的用户界面开发'', ''15-30K'');

INSERT INTO careers (title, description, average_salary)
VALUES (''后端开发工程师'', ''负责服务器端应用程序和系统架构开发'', ''20-40K'');

INSERT INTO careers (title, description, average_salary)
VALUES (''全栈开发工程师'', ''同时掌握前端和后端技术的全面开发者'', ''25-45K'');

-- 职业所需技能
INSERT INTO career_required_skills (career_id, skill) VALUES (1, ''JavaScript'');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, ''React'');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, ''Vue'');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, ''HTML/CSS'');

INSERT INTO career_required_skills (career_id, skill) VALUES (2, ''Java'');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, ''Spring Boot'');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, ''MySQL'');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, ''Redis'');

INSERT INTO career_required_skills (career_id, skill) VALUES (3, ''JavaScript'');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, ''Node.js'');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, ''React'');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, ''MongoDB'');
'

# 创建证书相关的DTO和服务类
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

create_file "$BASE_DIR/$PACKAGE_PATH/service/CertificateService.java" '
package com.university.careerplanning.service;

import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.Certificate;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.CertificateRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class CertificateService {

    @Autowired
    private CertificateRepository certificateRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Certificate> getCertificatesByUserId(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        return certificateRepository.findByUser(user);
    }

    public Certificate getCertificateById(Long certificateId) {
        return certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
    }

    @Transactional
    public Certificate createCertificate(Long userId, Certificate certificate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        certificate.setUser(user);
        
        // 转换日期字符串为LocalDate
        if (certificate.getIssueDate() == null) {
            certificate.setIssueDate(LocalDate.now());
        }
        
        return certificateRepository.save(certificate);
    }

    @Transactional
    public Certificate updateCertificate(Long certificateId, Certificate updatedCertificate) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
                
        // 更新字段
        certificate.setName(updatedCertificate.getName());
        certificate.setIssuer(updatedCertificate.getIssuer());
        
        if (updatedCertificate.getIssueDate() != null) {
            certificate.setIssueDate(updatedCertificate.getIssueDate());
        }
        
        if (updatedCertificate.getExpiryDate() != null) {
            certificate.setExpiryDate(updatedCertificate.getExpiryDate());
        }
        
        if (updatedCertificate.getDescription() != null) {
            certificate.setDescription(updatedCertificate.getDescription());
        }
        
        return certificateRepository.save(certificate);
    }

    @Transactional
    public void deleteCertificate(Long certificateId) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
                
        certificateRepository.delete(certificate);
    }
}
'

echo "项目创建完成！目录结构如下："
find "$BASE_DIR" -type f -name "*.java" | sort

echo "启动指南："
echo "1. 进入项目目录: cd $BASE_DIR"
echo "2. 使用Maven编译: mvn clean package"
echo "3. 运行应用: java -jar target/career-planning-0.0.1-SNAPSHOT.jar"
echo "或者使用Maven直接运行: mvn spring-boot:run"
echo ""
echo "默认用户名: admin 密码: password"
echo "H2数据库控制台: http://localhost:8080/h2-console"
echo "API文档: 可以使用Swagger或Postman测试API"
