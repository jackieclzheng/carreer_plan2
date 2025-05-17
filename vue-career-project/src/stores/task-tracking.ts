import { defineStore } from 'pinia';
import { apiService } from '@/services/api';
import axios from 'axios';

interface Task {
  id: number;
  title: string;
  description: string;
  deadline: string;
  status: '未开始' | '进行中' | '已完成';
  progress: number;
}

interface TaskInput {
  title: string;
  description: string;
  deadline: string;
  status: '未开始' | '进行中' | '已完成';
  progress: number;
}

export const useTaskTrackingStore = defineStore('taskTracking', {
  state: () => ({
    tasks: [] as Task[],
    loading: false,
    error: null as string | null
  }),

  getters: {
    taskStats: (state) => ({
      total: state.tasks.length,
      completed: state.tasks.filter(t => t.status === '已完成').length,
      inProgress: state.tasks.filter(t => t.status === '进行中').length,
      notStarted: state.tasks.filter(t => t.status === '未开始').length
    })
  },

  actions: {
    // 获取所有任务
    async fetchTasks() {
      try {
        this.loading = true;
        this.error = null;
        
        const { data } = await apiService.get('/tasks');
        this.tasks = data;
      } catch (error) {
        console.error('获取任务失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '获取任务失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 添加新任务
    async addTask(task: TaskInput) {
      try {
        this.loading = true;
        this.error = null;
        
        const { data } = await apiService.post('/tasks', task);
        this.tasks.push(data);
        return data;
      } catch (error) {
        console.error('添加任务失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '添加任务失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新任务
    async updateTask(id: number, updates: Partial<TaskInput>) {
      try {
        this.loading = true;
        this.error = null;
        
        const { data } = await apiService.patch(`/tasks/${id}`, updates);
        const index = this.tasks.findIndex(t => t.id === id);
        if (index !== -1) {
          this.tasks[index] = data;
        }
        return data;
      } catch (error) {
        console.error('更新任务失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '更新任务失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 删除任务
    async removeTask(id: number) {
      try {
        this.loading = true;
        this.error = null;
        
        await apiService.delete(`/tasks/${id}`);
        this.tasks = this.tasks.filter(task => task.id !== id);
      } catch (error) {
        console.error('删除任务失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '删除任务失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新任务进度
    async updateTaskProgress(id: number, progress: number) {
      try {
        this.loading = true;
        this.error = null;
        
        const { data } = await apiService.patch(`/tasks/${id}/progress`, { progress });
        const index = this.tasks.findIndex(t => t.id === id);
        if (index !== -1) {
          this.tasks[index] = data;
        }
        return data;
      } catch (error) {
        console.error('更新进度失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '更新进度失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 批量更新任务状态
    async updateTasksStatus(ids: number[], status: Task['status']) {
      try {
        this.loading = true;
        this.error = null;
        
        const { data } = await apiService.patch('/tasks/batch-update', { ids, status });
        data.forEach(updatedTask => {
          const index = this.tasks.findIndex(t => t.id === updatedTask.id);
          if (index !== -1) {
            this.tasks[index] = updatedTask;
          }
        });
        return data;
      } catch (error) {
        console.error('批量更新状态失败:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '批量更新状态失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
