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
create_file "$BASE_DIR/$PACKAGE_PATH/controller/CareerPlanController.java" '
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CareerDirectionDTO;
import com.university.careerplanning.dto.CareerPlanDTO;
import com.university.careerplanning.dto.SkillStatusUpdateRequest;
import com.university.careerplanning.model.CareerPlan;
import com.university.careerplanning.service.CareerPlanService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/career-planning")
public class CareerPlanController {

    