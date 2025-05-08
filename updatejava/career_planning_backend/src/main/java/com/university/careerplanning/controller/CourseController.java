
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

