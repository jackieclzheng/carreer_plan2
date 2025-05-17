create_file "$BASE_DIR/$PACKAGE_PATH/dto/SkillSemesterGoalDTO.java" '
package com.university.careerplanning.dto;

public class SkillSemesterGoalDTO {
    private String name;
    private String semesterGoal;
    private String status;
    
    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSemesterGoal() { return semesterGoal; }
    public void setSemesterGoal(String semesterGoal) { this.semesterGoal = semesterGoal; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SemesterCourseDTO.java" '
package com.university.careerplanning.dto;

public class SemesterCourseDTO {
    private String name;
    private String semester;
    
    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SemesterCertificateDTO.java" '
package com.university.careerplanning.dto;

public class SemesterCertificateDTO {
    private String name;
    private String semester;
    
    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/CareerPlanDTO.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class CareerPlanDTO {
    private String targetCareer;
    private List<SemesterPlanDTO> semesters;
    
    // Getters and Setters
    public String getTargetCareer() { return targetCareer; }
    public void setTargetCareer(String targetCareer) { this.targetCareer = targetCareer; }
    
    public List<SemesterPlanDTO> getSemesters() { return semesters; }
    public void setSemesters(List<SemesterPlanDTO> semesters) { this.semesters = semesters; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SemesterPlanDTO.java" '
package com.university.careerplanning.dto;

import java.util.List;

public class SemesterPlanDTO {
    private String semester;
    private List<SkillSemesterGoalDTO> skills;
    private List<SemesterCourseDTO> courses;
    private List<SemesterCertificateDTO> certificates;
    
    // Getters and Setters
    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }
    
    public List<SkillSemesterGoalDTO> getSkills() { return skills; }
    public void setSkills(List<SkillSemesterGoalDTO> skills) { this.skills = skills; }
    
    public List<SemesterCourseDTO> getCourses() { return courses; }
    public void setCourses(List<SemesterCourseDTO> courses) { this.courses = courses; }
    
    public List<SemesterCertificateDTO> getCertificates() { return certificates; }
    public void setCertificates(List<SemesterCertificateDTO> certificates) { this.certificates = certificates; }
}
'

create_file "$BASE_DIR/$PACKAGE_PATH/dto/SkillStatusUpdateRequest.java" '
package com.university.careerplanning.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public class SkillStatusUpdateRequest {
    @Min(value = 0, message = "学期索引不能小于0")
    private int semesterIndex;
    
    @Min(value = 0, message = "技能索引不能小于0")
    private int skillIndex;
    
    @NotBlank(message = "新状态不能为空")
    private String newStatus;
    
    // Getters and Setters
    public int getSemesterIndex() { return semesterIndex; }
    public void setSemesterIndex(int semesterIndex) { this.semesterIndex = semesterIndex; }
    
    public int getSkillIndex() { return skillIndex; }
    public void setSkillIndex(int skillIndex) { this.skillIndex = skillIndex; }
    
    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }
}
'

# 29. 用户服务
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

# 30. 自定义用户详情服务
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

# 31. 证书服务
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