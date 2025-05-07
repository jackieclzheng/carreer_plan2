import { defineStore } from 'pinia';

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

        const response = await fetch('/api/tasks');
        if (!response.ok) throw new Error('获取任务列表失败');

        const data = await response.json();
        this.tasks = data;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取任务失败';
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

        const response = await fetch('/api/tasks', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(task),
        });

        if (!response.ok) throw new Error('添加任务失败');

        const newTask = await response.json();
        this.tasks.push(newTask);
        return newTask;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '添加任务失败';
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

        const response = await fetch(`/api/tasks/${id}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(updates),
        });

        if (!response.ok) throw new Error('更新任务失败');

        const updatedTask = await response.json();
        const index = this.tasks.findIndex(t => t.id === id);
        if (index !== -1) {
          this.tasks[index] = updatedTask;
        }
      } catch (error) {
        this.error = error instanceof Error ? error.message : '更新任务失败';
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

        const response = await fetch(`/api/tasks/${id}`, {
          method: 'DELETE',
        });

        if (!response.ok) throw new Error('删除任务失败');

        this.tasks = this.tasks.filter(task => task.id !== id);
      } catch (error) {
        this.error = error instanceof Error ? error.message : '删除任务失败';
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

        const response = await fetch(`/api/tasks/${id}/progress`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ progress }),
        });

        if (!response.ok) throw new Error('更新进度失败');

        const updatedTask = await response.json();
        const index = this.tasks.findIndex(t => t.id === id);
        if (index !== -1) {
          this.tasks[index] = updatedTask;
        }
      } catch (error) {
        this.error = error instanceof Error ? error.message : '更新进度失败';
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

        const response = await fetch('/api/tasks/batch-update', {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ ids, status }),
        });

        if (!response.ok) throw new Error('批量更新状态失败');

        const updatedTasks = await response.json();
        updatedTasks.forEach(updatedTask => {
          const index = this.tasks.findIndex(t => t.id === updatedTask.id);
          if (index !== -1) {
            this.tasks[index] = updatedTask;
          }
        });
      } catch (error) {
        this.error = error instanceof Error ? error.message : '批量更新状态失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
