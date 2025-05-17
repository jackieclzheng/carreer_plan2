
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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/careers")
public class CareerController {

    @Autowired
    private CareerService careerService;
    
    @Autowired
    private UserService userService;

//    @GetMapping("/search")
//    public ResponseEntity<SearchResponse> searchCareers(
//            @RequestParam("q") String query,
//            @RequestParam(value = "page", defaultValue = "0") int page,
//            @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {
//
//        Pageable pageable = PageRequest.of(page, pageSize);
//        Page<Career> careerPage = careerService.searchCareers(query, pageable);
//
//        List<CareerDTO> careerDTOs = careerPage.getContent().stream()
//                .map(this::convertToDTO)
//                .collect(Collectors.toList());
//
//        SearchResponse response = new SearchResponse();
//        response.setCareers(careerDTOs);
//        response.setTotal(careerPage.getTotalElements());
//        response.setPage(page);
//        response.setPageSize(pageSize);
//
//        return ResponseEntity.ok(response);
//    }

    @GetMapping("/search")
    public ResponseEntity<SearchResponse> searchCareers(
            @RequestParam("q") String query,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {

        // 直接在方法内构造15条假数据
        List<Career> mockCareers = new ArrayList<>();

        // 添加假数据
        Career career1 = new Career();
        career1.setId(1L);
        career1.setTitle("前端开发工程师");
        career1.setDescription("负责Web前端页面的设计和开发，确保用户界面友好且功能完整。");
        career1.setRequiredSkills(Arrays.asList("JavaScript", "HTML", "CSS", "Vue", "React"));
        career1.setAverageSalary("18000-25000");
        mockCareers.add(career1);

        Career career2 = new Career();
        career2.setId(2L);
        career2.setTitle("后端开发工程师");
        career2.setDescription("负责服务器端应用程序的设计和实现，确保系统性能和稳定性。");
        career2.setRequiredSkills(Arrays.asList("Java", "Spring Boot", "MySQL", "Redis", "微服务"));
        career2.setAverageSalary("20000-30000");
        mockCareers.add(career2);

        Career career3 = new Career();
        career3.setId(3L);
        career3.setTitle("数据分析师");
        career3.setDescription("通过收集、处理和分析数据，为业务决策提供数据支持。");
        career3.setRequiredSkills(Arrays.asList("SQL", "Python", "Excel", "数据可视化", "统计学"));
        career3.setAverageSalary("15000-22000");
        mockCareers.add(career3);

        Career career4 = new Career();
        career4.setId(4L);
        career4.setTitle("产品经理");
        career4.setDescription("负责产品的规划、设计和管理，协调各部门完成产品开发。");
        career4.setRequiredSkills(Arrays.asList("需求分析", "产品规划", "用户体验", "项目管理", "沟通能力"));
        career4.setAverageSalary("18000-28000");
        mockCareers.add(career4);

        Career career5 = new Career();
        career5.setId(5L);
        career5.setTitle("UI/UX设计师");
        career5.setDescription("负责用户界面和用户体验设计，确保产品视觉吸引力和易用性。");
        career5.setRequiredSkills(Arrays.asList("Figma", "Sketch", "用户研究", "交互设计", "视觉设计"));
        career5.setAverageSalary("15000-25000");
        mockCareers.add(career5);

        // 根据query参数筛选数据
        List<Career> filteredCareers = mockCareers;
        if (query != null && !query.trim().isEmpty()) {
            String lowercaseQuery = query.toLowerCase();
            filteredCareers = mockCareers.stream()
                    .filter(c ->
                            c.getTitle().toLowerCase().contains(lowercaseQuery) ||
                                    c.getDescription().toLowerCase().contains(lowercaseQuery) ||
                                    c.getRequiredSkills().stream().anyMatch(skill -> skill.toLowerCase().contains(lowercaseQuery))
                    )
                    .collect(Collectors.toList());
        }

        // 计算分页
        int start = Math.min(page * pageSize, filteredCareers.size());
        int end = Math.min(start + pageSize, filteredCareers.size());
        List<Career> paginatedList = filteredCareers.subList(start, end);

        // 转换为DTO
        List<CareerDTO> careerDTOs = new ArrayList<>();
        for (Career career : paginatedList) {
            CareerDTO dto = new CareerDTO();
            dto.setId(career.getId());
            dto.setTitle(career.getTitle());
            dto.setDescription(career.getDescription());
            dto.setRequiredSkills(career.getRequiredSkills());
            dto.setAverageSalary(career.getAverageSalary());
            careerDTOs.add(dto);
        }

        // 构建响应
        SearchResponse response = new SearchResponse();
        response.setCareers(careerDTOs);
        response.setTotal(filteredCareers.size());
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

