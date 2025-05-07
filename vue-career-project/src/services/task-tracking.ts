import { defineStore } from 'pinia';
import type { Task } from '@/types';

export const useTaskTrackingStore = defineStore('taskTracking', {
  state: () => ({
    tasks: [
      {
        id: 1,
        title: '完成React高级课程',
        description: '学习React高级开发技巧',
        deadline: '2024-08-30',
        status: '进行中',
        progress: 60
      },
      {
        id: 2,
        title: '参加全国软件开发大赛',
        description: '准备项目方案和演示',
        deadline: '2024-09-15',
        status: '未开始',
        progress: 10
      }
    ]
  }),

  getters: {
    taskStats() {
      return {
        total: this.tasks.length,
        completed: this.tasks.filter(t => t.status === '已完成').length,
        inProgress: this.tasks.filter(t => t.status === '进行中').length,
        notStarted: this.tasks.filter(t => t.status === '未开始').length
      };
    }
  },

  actions: {
    // 添加任务
    addTask(task: Omit<Task, 'id'>) {
      const newTask = {
        ...task,
        id: this.tasks.length + 1
      };
      this.tasks.push(newTask);
    },

    // 更新任务
    updateTask(id: number, updatedTask: Partial<Task>) {
      const index = this.tasks.findIndex(task => task.id === id);
      if (index !== -1) {
        this.tasks[index] = {
          ...this.tasks[index],
          ...updatedTask
        };
      }
    },

    // 删除任务
    removeTask(id: number) {
      const index = this.tasks.findIndex(task => task.id === id);
      if (index !== -1) {
        this.tasks.splice(index, 1);
      }
    }
  }
});
