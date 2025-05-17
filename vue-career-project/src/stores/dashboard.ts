// src/stores/dashboard.ts
import { defineStore } from 'pinia';
import { apiService } from '@/services/api';
import axios from 'axios'; // 导入 axios 用于类型检查

// 定义类型接口
interface KeyMetric {
  id: number;
  title: string;
  value: number;
  change: number;
  trend: 'up' | 'down' | 'neutral';
}

interface SkillProgress {
  id: number;
  name: string;
  progress: number;
  target: number;
}

interface RecentActivity {
  id: number;
  type: string;
  description: string;
  date: string;
  status: string;
}

interface DashboardData {
  overallProgress: number;
  currentGoal: string;
  keyMetrics: KeyMetric[];
  skillProgress: SkillProgress[];
  recentActivities: RecentActivity[];
}

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    overallProgress: 0,
    currentGoal: '',
    keyMetrics: [] as KeyMetric[],
    skillProgress: [] as SkillProgress[],
    recentActivities: [] as RecentActivity[],
    loading: false,
    error: null as string | null
  }),

  actions: {
    // 获取仪表盘所有数据
    async fetchDashboardData() {
      try {
        this.loading = true;
        this.error = null;
        
        // 使用相对路径，apiService 会自动添加基础 URL
        const { data } = await apiService.get('/dashboard', {
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
          }
        });
        
        this.updateDashboardData(data);
      } catch (error) {
        console.error('Dashboard store error:', error);
        this.error = axios.isAxiosError(error) 
          ? error.message || '请求失败' 
          : '获取数据失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 添加更新仪表盘数据的方法
    updateDashboardData(rawData: any) {
      // 数据转换和验证
      const data: DashboardData = {
        overallProgress: Number(rawData.overallProgress) || 0,
        currentGoal: String(rawData.currentGoal) || '',
        keyMetrics: Array.isArray(rawData.keyMetrics) ? rawData.keyMetrics : [],
        skillProgress: Array.isArray(rawData.skillProgress) ? rawData.skillProgress : [],
        recentActivities: Array.isArray(rawData.recentActivities) ? rawData.recentActivities : []
      };

      // 更新 store 状态
      this.overallProgress = data.overallProgress;
      this.currentGoal = data.currentGoal;
      this.keyMetrics = data.keyMetrics;
      this.skillProgress = data.skillProgress;
      this.recentActivities = data.recentActivities;
    },

    // 更新目标
    async updateCurrentGoal(goal: string) {
      try {
        this.loading = true;
        this.error = null;

        // 使用 apiService 发送更新请求
        const { data } = await apiService.put('/dashboard/goal', { goal });
        
        this.currentGoal = data.goal;
      } catch (error) {
        this.error = axios.isAxiosError(error) 
          ? error.message || '更新目标失败' 
          : '更新目标失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新技能进度
    async updateSkillProgress(skillId: number, progress: number) {
      try {
        this.loading = true;
        this.error = null;

        // 使用 apiService 发送更新请求
        const { data } = await apiService.patch(
          `/dashboard/skills/${skillId}`,
          { progress }
        );
        
        const index = this.skillProgress.findIndex(s => s.id === skillId);
        if (index !== -1) {
          this.skillProgress[index] = data;
        }
      } catch (error) {
        this.error = axios.isAxiosError(error) 
          ? error.message || '更新技能进度失败' 
          : '更新技能进度失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 获取最近活动
    async fetchRecentActivities() {
      try {
        this.loading = true;
        this.error = null;

        // 使用 apiService 获取数据
        const { data } = await apiService.get('/dashboard/activities');
        
        this.recentActivities = data;
      } catch (error) {
        this.error = axios.isAxiosError(error) 
          ? error.message || '获取最近活动失败' 
          : '获取最近活动失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 获取关键指标
    async fetchKeyMetrics() {
      try {
        this.loading = true;
        this.error = null;

        // 使用 apiService 获取数据
        const { data } = await apiService.get('/dashboard/metrics');
        
        this.keyMetrics = data;
      } catch (error) {
        this.error = axios.isAxiosError(error) 
          ? error.message || '获取关键指标失败' 
          : '获取关键指标失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});