
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

