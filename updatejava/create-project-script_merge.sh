#!/bin/bash

# 创建目录脚本 - 职业规划系统

# 设置基础目录
BASE_DIR="career_planning_backend"
PACKAGE_PATH="src/main/java/com/university/careerplanning"
RESOURCES_PATH="src/main/resources"

# 创建基础目录结构
mkdir -p "$BASE_DIR/$PACKAGE_PATH/config"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/controller"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/dto"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/exception"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/model"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/repository"
mkdir -p "$BASE_DIR/$PACKAGE_PATH/service"
mkdir -p "$BASE_DIR/$RESOURCES_PATH"

# 复制创建文件的函数
create_file() {
  local file_path="$1"
  local content="$2"
  mkdir -p "$(dirname "$file_path")"
  echo "$content" > "$file_path"
  echo "创建文件: $file_path"
}

# 1. 应用主类
create_file "$BASE_DIR/$PACKAGE_PATH/CareerPlanningApplication.java" '
package com.university.careerplanning;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CareerPlanningApplication {
    public static void main(String[] args) {
        SpringApplication.run(CareerPlanningApplication.class, args);
    }
}
'

# 2. 应用配置
create_file "$BASE_DIR/$RESOURCES_PATH/application.yml" '
spring:
  datasource:
    url: jdbc:h2:mem:career_planning_db
    username: sa
    password: 
    driver-class-name: org.h2.Driver
  
  h2:
    console:
      enabled: true
      path: /h2-console
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.H2Dialect

server:
  port: 8080

# JWT 配置
jwt:
  access-token-expiration: 3600000  # 1小时 (毫秒)
  refresh-token-expiration: 604800000  # 7天 (毫秒)

# 日志配置
logging:
  level:
    org.springframework.web: INFO
    org.hibernate: ERROR
    com.university.careerplanning: DEBUG

# 跨域配置
cors:
  allowed-origins: http://localhost:3000
  allowed-methods: GET,POST,PUT,DELETE,OPTIONS
  allowed-headers: "*"
  max-age: 3600

# 应用程序特定配置
app:
  security:
    jwt-secret: career_planning_secret_key_for_development_only
'

# 3. 安全配置
create_file "$BASE_DIR/$PACKAGE_PATH/config/SecurityConfig.java" '
package com.university.careerplanning.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import com.university.careerplanning.service.CustomUserDetailsService;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final CustomUserDetailsService userDetailsService;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter, CustomUserDetailsService userDetailsService) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(authz -> authz
                .requestMatchers(new AntPathRequestMatcher("/api/public/**")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/api/auth/**")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/h2-console/**")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/api/user/**")).authenticated()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        
        // 允许H2控制台框架页面
        http.headers(headers -> headers.frameOptions(frameOptions -> frameOptions.disable()));
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }
    
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
}
'

# 4. JWT相关配置
create_file "$BASE_DIR/$PACKAGE_PATH/config/JwtTokenProvider.java" '
package com.university.careerplanning.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtTokenProvider {

    @Value("${app.security.jwt-secret}")
    private String jwtSecret;

    @Value("${jwt.access-token-expiration}")
    private long jwtExpirationMs;

    private Key getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername());
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/config/JwtAuthenticationFilter.java" '
package com.university.careerplanning.config;

import com.university.careerplanning.service.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
        HttpServletRequest request, 
        HttpServletResponse response, 
        FilterChain filterChain
    ) throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        final String jwt = authHeader.substring(7);
        final String username = jwtTokenProvider.extractUsername(jwt);

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            if (jwtTokenProvider.validateToken(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails, 
                    null, 
                    userDetails.getAuthorities()
                );
                
                authToken.setDetails(
                    new WebAuthenticationDetailsSource().buildDetails(request)
                );
                
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
'

# 5. Web配置
create_file "$BASE_DIR/$PACKAGE_PATH/config/WebConfig.java" '
package com.university.careerplanning.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Value("${cors.allowed-origins}")
    private String[] allowedOrigins;

    @Value("${cors.allowed-methods}")
    private String[] allowedMethods;

    @Value("${cors.allowed-headers}")
    private String[] allowedHeaders;

    @Value("${cors.max-age}")
    private long maxAge;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(allowedOrigins)
                .allowedMethods(allowedMethods)
                .allowedHeaders(allowedHeaders)
                .maxAge(maxAge)
                .allowCredentials(true);
    }
}
'

# 6. 异常处理
create_file "$BASE_DIR/$PACKAGE_PATH/exception/ResourceNotFoundException.java" '
package com.university.careerplanning.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }

    public ResourceNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/exception/GlobalExceptionHandler.java" '
package com.university.careerplanning.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
        ResourceNotFoundException ex, 
        WebRequest request
    ) {
        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.NOT_FOUND.value(),
            "资源未找到",
            ex.getMessage()
        );
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Object> handleValidationExceptions(
        MethodArgumentNotValidException ex
    ) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
        Exception ex, 
        WebRequest request
    ) {
        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "服务器内部错误",
            ex.getMessage()
        );
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // 错误响应实体
    public static class ErrorResponse {
        private LocalDateTime timestamp;
        private int status;
        private String error;
        private String message;

        public ErrorResponse(LocalDateTime timestamp, int status, String error, String message) {
            this.timestamp = timestamp;
            this.status = status;
            this.error = error;
            this.message = message;
        }

        // Getters and setters
        public LocalDateTime getTimestamp() { return timestamp; }
        public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
        public int getStatus() { return status; }
        public void setStatus(int status) { this.status = status; }
        public String getError() { return error; }
        public void setError(String error) { this.error = error; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
'

# 7. 用户模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/User.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String major;

    @Column(nullable = false)
    private LocalDate enrollmentDate;

    @OneToMany(mappedBy = "user")
    private List<CareerPlan> careerPlans;

    @OneToMany(mappedBy = "user")
    private List<Certificate> certificates;

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMajor() {
        return major;
    }

    public void setMajor(String major) {
        this.major = major;
    }

    public LocalDate getEnrollmentDate() {
        return enrollmentDate;
    }

    public void setEnrollmentDate(LocalDate enrollmentDate) {
        this.enrollmentDate = enrollmentDate;
    }

    public List<CareerPlan> getCareerPlans() {
        return careerPlans;
    }

    public void setCareerPlans(List<CareerPlan> careerPlans) {
        this.careerPlans = careerPlans;
    }

    public List<Certificate> getCertificates() {
        return certificates;
    }

    public void setCertificates(List<Certificate> certificates) {
        this.certificates = certificates;
    }
}
'

# 8. 证书模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/Certificate.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "certificates")
public class Certificate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String issuer;

    @Column(nullable = false)
    private LocalDate issueDate;

    @Column
    private LocalDate expiryDate;

    @Column
    private String description;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIssuer() {
        return issuer;
    }

    public void setIssuer(String issuer) {
        this.issuer = issuer;
    }

    public LocalDate getIssueDate() {
        return issueDate;
    }

    public void setIssueDate(LocalDate issueDate) {
        this.issueDate = issueDate;
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
'

# 9. 职业规划模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/CareerPlan.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "career_plans")
public class CareerPlan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String careerDirection;

    @Column(nullable = false)
    private LocalDate startDate = LocalDate.now();

    @Column
    private LocalDate endDate;

    @Column
    private String status;

    // 技能和目标可以作为 JSON 存储或创建独立的实体
    @Column(columnDefinition = "TEXT")
    private String skills;

    @Column(columnDefinition = "TEXT")
    private String goals;

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getCareerDirection() {
        return careerDirection;
    }

    public void setCareerDirection(String careerDirection) {
        this.careerDirection = careerDirection;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSkills() {
        return skills;
    }

    public void setSkills(String skills) {
        this.skills = skills;
    }

    public String getGoals() {
        return goals;
    }

    public void setGoals(String goals) {
        this.goals = goals;
    }
}
'

# 10. 课程模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/Course.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;

@Entity
@Table(name = "courses")
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String semester;

    @Column(nullable = false)
    private int score;

    @Column(nullable = false)
    private int credits;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getCredits() {
        return credits;
    }

    public void setCredits(int credits) {
        this.credits = credits;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
'

# 11. 任务模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/Task.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "tasks")
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column
    private String description;

    @Column(nullable = false)
    private LocalDate deadline;

    @Column(nullable = false)
    private String status; // "未开始", "进行中", "已完成"

    @Column(nullable = false)
    private int progress; // 0-100

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDate getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDate deadline) {
        this.deadline = deadline;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
'

# 12. 职业模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/Career.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "careers")
public class Career {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @ElementCollection
    @CollectionTable(name = "career_required_skills", joinColumns = @JoinColumn(name = "career_id"))
    @Column(name = "skill")
    private List<String> requiredSkills;

    @Column(nullable = false)
    private String averageSalary;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<String> getRequiredSkills() {
        return requiredSkills;
    }

    public void setRequiredSkills(List<String> requiredSkills) {
        this.requiredSkills = requiredSkills;
    }

    public String getAverageSalary() {
        return averageSalary;
    }

    public void setAverageSalary(String averageSalary) {
        this.averageSalary = averageSalary;
    }
}
'

# 13. 收藏职业模型
create_file "$BASE_DIR/$PACKAGE_PATH/model/SavedCareer.java" '
package com.university.careerplanning.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "saved_careers")
public class SavedCareer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "career_id", nullable = false)
    private Career career;

    @Column(nullable = false)
    private LocalDateTime savedAt = LocalDateTime.now();

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Career getCareer() {
        return career;
    }

    public void setCareer(Career career) {
        this.career = career;
    }

    public LocalDateTime getSavedAt() {
        return savedAt;
    }

    public void setSavedAt(LocalDateTime savedAt) {
        this.savedAt = savedAt;
    }
}
'

# 14. 用户仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/UserRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
'

# 15. 证书仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/CertificateRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.Certificate;
import com.university.careerplanning.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CertificateRepository extends JpaRepository<Certificate, Long> {
    List<Certificate> findByUser(User user);
}
'

# 16. 职业规划仓库
create_file "$BASE_DIR/$PACKAGE_PATH/repository/CareerPlanRepository.java" '
package com.university.careerplanning.repository;

import com.university.careerplanning.model.CareerPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CareerPlanRepository extends JpaRepository<CareerPlan, Long> {
    Optional<CareerPlan> findByUserIdAndStatus(Long userId, String status);
    
    @Modifying
    @Query("UPDATE CareerPlan cp SET cp.status = '\''inactive'\'' WHERE cp.user.id = :userId")
    void deactivateAllUserPlans(@Param("userId") Long userId);
}'

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
        cert1.setName("SemesterCertificateDTO cert1 = new SemesterCertificateDTO();
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
# 40. 任务控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/TaskController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.BatchStatusUpdateRequest;
import com.university.careerplanning.dto.ProgressUpdateRequest;
import com.university.careerplanning.dto.TaskDTO;
import com.university.careerplanning.model.Task;
import com.university.careerplanning.service.TaskService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    @Autowired
    private TaskService taskService;
    
    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<TaskDTO>> getTasks(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Task> tasks = taskService.getTasksByUserId(userId);
        
        List<TaskDTO> taskDTOs = tasks.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(taskDTOs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaskDTO> getTaskById(@PathVariable Long id) {
        Task task = taskService.getTaskById(id);
        return ResponseEntity.ok(convertToDTO(task));
    }

    @PostMapping
    public ResponseEntity<TaskDTO> createTask(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody TaskDTO taskDTO) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        Task task = convertToEntity(taskDTO);
        Task savedTask = taskService.createTask(userId, task);
        
        return ResponseEntity.ok(convertToDTO(savedTask));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TaskDTO> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody TaskDTO taskDTO) {
        
        Task task = convertToEntity(taskDTO);
        Task updatedTask = taskService.updateTask(id, task);
        
        return ResponseEntity.ok(convertToDTO(updatedTask));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTask(@PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.ok().build();
    }
    
    @PatchMapping("/{id}/progress")
    public ResponseEntity<TaskDTO> updateTaskProgress(
            @PathVariable Long id,
            @Valid @RequestBody ProgressUpdateRequest request) {
        
        Task updatedTask = taskService.updateTaskProgress(id, request.getProgress());
        return ResponseEntity.ok(convertToDTO(updatedTask));
    }
    
    @PatchMapping("/batch-update")
    public ResponseEntity<List<TaskDTO>> updateTasksStatus(
            @Valid @RequestBody BatchStatusUpdateRequest request) {
        
        List<Task> updatedTasks = taskService.updateTasksStatus(request.getIds(), request.getStatus());
        
        List<TaskDTO> taskDTOs = updatedTasks.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(taskDTOs);
    }
    
    // 辅助方法：将实体转换为DTO
    private TaskDTO convertToDTO(Task task) {
        TaskDTO dto = new TaskDTO();
        dto.setId(task.getId());
        dto.setTitle(task.getTitle());
        dto.setDescription(task.getDescription());
        
        if (task.getDeadline() != null) {
            dto.setDeadline(task.getDeadline().format(DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        dto.setStatus(task.getStatus());
        dto.setProgress(task.getProgress());
        
        return dto;
    }
    
    // 辅助方法：将DTO转换为实体
    private Task convertToEntity(TaskDTO dto) {
        Task task = new Task();
        
        if (dto.getId() != null) {
            task.setId(dto.getId());
        }
        
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        
        if (dto.getDeadline() != null && !dto.getDeadline().isEmpty()) {
            task.setDeadline(LocalDate.parse(dto.getDeadline(), DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        task.setStatus(dto.getStatus());
        task.setProgress(dto.getProgress());
        
        return task;
    }
}
'

# 41. 职业搜索控制器
create_file "$BASE_DIR/$PACKAGE_PATH/controller/CareerController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerDTO;
import com.university.careerplanning.dto.SaveCareerRequest;
import com.university.careerplanning.dto.SearchResponse;
import com.university.careerplanning.model.Career;
import com.university.careerplanning.model.SavedCareer;
import com.university.careerplanning.service.CareerService;
import com.university.careerplanning.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/careers")
public class CareerController {

    @Autowired
    private CareerService careerService;
    
    @Autowired
    private UserService userService;

    @GetMapping("/search")
    public ResponseEntity<SearchResponse> searchCareers(
            @RequestParam("q") String query,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {
        
        Pageable pageable = PageRequest.of(page, pageSize);
        Page<Career> careerPage = careerService.searchCareers(query, pageable);
        
        List<CareerDTO> careerDTOs = careerPage.getContent().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        SearchResponse response = new SearchResponse();
        response.setCareers(careerDTOs);
        response.setTotal(careerPage.getTotalElements());
        response.setPage(page);
        response.setPageSize(pageSize);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CareerDTO> getCareerById(@PathVariable Long id) {
        Career career = careerService.getCareerById(id);
        return ResponseEntity.ok(convertToDTO(career));
    }

    @GetMapping("/recommended")
    public ResponseEntity<List<CareerDTO>> getRecommendedCareers(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Career> recommendedCareers = careerService.getRecommendedCareers(userId);
        
        List<CareerDTO> careerDTOs = recommendedCareers.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(careerDTOs);
    }

    @PostMapping("/saved")
    public ResponseEntity<?> saveCareer(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody SaveCareerRequest request) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        SavedCareer savedCareer = careerService.saveCareer(userId, request.getCareerId());
        
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/saved/{careerId}")
    public ResponseEntity<?> unsaveCareer(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long careerId) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        careerService.unsaveCareer(userId, careerId);
        
        return ResponseEntity.ok().build();
    }

    @GetMapping("/saved")
    public ResponseEntity<List<CareerDTO>> getSavedCareers(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Career> savedCareers = careerService.getSavedCareers(userId);
        
        List<CareerDTO> careerDTOs = savedCareers.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(careerDTOs);
    }
    
    // 辅助方法：将实体转换为DTO
    private CareerDTO convertToDTO(Career career) {
        CareerDTO dto = new CareerDTO();
        dto.setId(career.getId());
        dto.setTitle(career.getTitle());
        dto.setDescription(career.getDescription());
        dto.setRequiredSkills(career.getRequiredSkills());
        dto.setAverageSalary(career.getAverageSalary());
        
        return dto;
    }
}
'

# 42. 职业规划控制器
# create_file "$BASE_DIR/$PACKAGE_PATH/controller/CareerPlanController.java" '
# package com.university.careerplanning.controller;

# import com.university.careerplanning.dto.CareerDirectionDTO;
# import com.university.careerplanning.dto.CareerPlanDTO;
# import com.university.careerplanning.dto.SkillStatusUpdateRequest;
# import com.university.careerplanning.model.CareerPlan;
# import com.university.careerplanning.service.CareerPlanService;
# import com.university.careerplanning.service.UserService;
# import jakarta.validation.Valid;
# import org.springframework.beans.factory.annotation.Autowired;
# import org.springframework.http.ResponseEntity;
# import org.springframework.security.core.annotation.AuthenticationPrincipal;
# import org.springframework.security.core.userdetails.UserDetails;
# import org.springframework.web.bind.annotation.*;

# import java.util.ArrayList;
# import java.util.List;

# @RestController
# @RequestMapping("/api/career-planning")
# public class CareerPlanController {

#!/bin/bash

# 设置基础目录
# BASE_DIR="career_planning_backend"
# PACKAGE_PATH="src/main/java/com/university/careerplanning"
# RESOURCES_PATH="src/main/resources"

# # 创建文件的函数
# create_file() {
#   local file_path="$1"
#   local content="$2"
#   mkdir -p "$(dirname "$file_path")"
#   echo "$content" > "$file_path"
#   echo "创建文件: $file_path"
# }

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

    

