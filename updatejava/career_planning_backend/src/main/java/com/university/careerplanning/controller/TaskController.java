
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

