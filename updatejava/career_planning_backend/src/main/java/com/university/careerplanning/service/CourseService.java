
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

