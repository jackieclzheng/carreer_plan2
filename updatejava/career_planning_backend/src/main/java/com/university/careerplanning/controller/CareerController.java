
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

