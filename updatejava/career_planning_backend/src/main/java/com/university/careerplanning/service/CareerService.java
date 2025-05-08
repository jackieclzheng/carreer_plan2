
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

