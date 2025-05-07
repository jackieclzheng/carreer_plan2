// src/stores/dashboard.ts
import { defineStore } from 'pinia';

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

        const response = await fetch('/api/dashboard');
        if (!response.ok) throw new Error('获取仪表盘数据失败');

        const data: DashboardData = await response.json();
        
        this.overallProgress = data.overallProgress;
        this.currentGoal = data.currentGoal;
        this.keyMetrics = data.keyMetrics;
        this.skillProgress = data.skillProgress;
        this.recentActivities = data.recentActivities;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取数据失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新目标
    async updateCurrentGoal(goal: string) {
      try {
        this.loading = true;
        this.error = null;

        const response = await fetch('/api/dashboard/goal', {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ goal }),
        });

        if (!response.ok) throw new Error('更新目标失败');

        const data = await response.json();
        this.currentGoal = data.goal;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '更新目标失败';
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

        const response = await fetch(`/api/dashboard/skills/${skillId}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ progress }),
        });

        if (!response.ok) throw new Error('更新技能进度失败');

        const updatedSkill = await response.json();
        const index = this.skillProgress.findIndex(s => s.id === skillId);
        if (index !== -1) {
          this.skillProgress[index] = updatedSkill;
        }
      } catch (error) {
        this.error = error instanceof Error ? error.message : '更新技能进度失败';
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

        const response = await fetch('/api/dashboard/activities');
        if (!response.ok) throw new Error('获取最近活动失败');

        const data = await response.json();
        this.recentActivities = data;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取最近活动失败';
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

        const response = await fetch('/api/dashboard/metrics');
        if (!response.ok) throw new Error('获取关键指标失败');

        const data = await response.json();
        this.keyMetrics = data;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取关键指标失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
