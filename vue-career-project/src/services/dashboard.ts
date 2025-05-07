// src/stores/dashboard.ts
import { defineStore } from 'pinia';
import type { DashboardData } from '@/types';

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    overallProgress: 45,
    currentGoal: '成为优秀的软件开发工程师',
    keyMetrics: [
      { 
        icon: 'book', 
        title: '累计学习课程', 
        value: 12, 
        color: 'bg-blue-100 text-blue-600' 
      },
      { 
        icon: 'trophy', 
        title: '获得证书', 
        value: 3, 
        color: 'bg-green-100 text-green-600' 
      },
      { 
        icon: 'star', 
        title: '完成项目', 
        value: 5, 
        color: 'bg-purple-100 text-purple-600' 
      }
    ],
    recentActivities: [
      { 
        title: '完成React高级课程', 
        date: '2024-03-15', 
        type: '学习' 
      },
      { 
        title: '获得JavaWeb开发证书', 
        date: '2024-02-20', 
        type: '认证' 
      },
      { 
        title: '参加全国软件开发大赛', 
        date: '2024-01-10', 
        type: '竞赛' 
      }
    ],
    skillProgress: [
      { name: 'JavaScript', progress: 75 },
      { name: 'React', progress: 60 },
      { name: 'Java', progress: 50 }
    ]
  }),

  actions: {
    // 可以添加更新仪表盘数据的方法
    async fetchDashboardData() {
      // 模拟从API获取数据
      try {
        // 实际应用中从后端获取数据
        return this.$state;
      } catch (error) {
        console.error('获取仪表盘数据失败', error);
      }
    }
  }
});
