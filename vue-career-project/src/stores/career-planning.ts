// src/stores/career-planning.ts
import { defineStore } from 'pinia'; 
import { apiService } from '@/services/api';  

interface CareerDirection {
  id: number;
  title: string;
  description?: string; 
}

interface Skill {
  name: string;
  semesterGoal: string;
  status: string;
}

interface Course {
  name: string;
  semester: string;
}

interface Certificate {
  name: string;
  semester: string;
}

interface Semester {
  semester: string;
  skills: Skill[];
  courses: Course[];
  certificates: Certificate[];
}

interface CareerPlan {
  targetCareer: string;
  semesters: Semester[];
}

export const useCareerPlanningStore = defineStore('careerPlanning', {
  state: () => ({
    personalizedPlan: null as CareerPlan | null,
    careerDirections: [
      { id: 1, title: '前端开发工程师', description: '专注于Web前端开发技术' },
      { id: 2, title: 'Java后端工程师', description: 'Java企业级应用开发' },
      { id: 3, title: 'Python开发工程师', description: 'Python应用开发和数据分析' },
      { id: 4, title: '全栈开发工程师', description: '前后端全栈开发技术' },
      { id: 5, title: '数据工程师', description: '大数据处理和分析' },
      { id: 6, title: 'DevOps工程师', description: '开发运维一体化' }
    ] as CareerDirection[],
    loading: false,
    error: null as string | null
  }),
 
  actions: {
    // 生成个性化职业规划
    async generatePersonalizedPlan(careerId: number) {
      console.log('[Store] 开始生成职业规划, careerId:', careerId);
      try {
        this.loading = true;
        this.error = null;
        console.log('[Store] 发送请求前, loading:', this.loading);
         
        // 发送请求到后端
        console.log('[Store] 发送请求...');
        const response = await apiService.post('/career-planning/generate', {
          careerId
        });
        console.log('[Store] 收到响应:', response);
         
        // 保存生成的规划
        this.personalizedPlan = response.data;
        console.log('[Store] 更新personalizedPlan成功');
        return response.data;
      } catch (error: any) {
        console.error('[Store] 生成职业规划失败:', error);
        this.error = error?.message || '生成规划失败';
        throw error;
      } finally {
        this.loading = false;
        console.log('[Store] 请求完成, loading:', this.loading);
      }
    },
   
    // 更新技能状态
    updateSkillStatus(semesterIndex: number, skillIndex: number, newStatus: string) {
      console.log('[Store] 更新技能状态', {semesterIndex, skillIndex, newStatus});
      if (this.personalizedPlan?.semesters) {
        const semester = this.personalizedPlan.semesters[semesterIndex];
        if (semester?.skills) {
          semester.skills[skillIndex].status = newStatus;
          console.log('[Store] 技能状态已更新');
        }
      }
    },
   
    // 获取职业方向列表
    async fetchCareerDirections() {
      console.log('[Store] 开始获取职业方向列表');
      try {
        this.loading = true;
        this.error = null;
        
        console.log('[Store] 发送获取职业方向请求...');
        const response = await apiService.get('/career-directions');
        console.log('[Store] 获取职业方向响应:', response);
        
        this.careerDirections = response.data;
        console.log('[Store] 职业方向列表已更新:', this.careerDirections);
        return response.data;
      } catch (error: any) {
        console.error('[Store] 获取职业方向失败:', error);
        this.error = error?.message || '获取职业方向失败';
        // 保留原始职业方向数据，避免出错时UI显示空白
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});