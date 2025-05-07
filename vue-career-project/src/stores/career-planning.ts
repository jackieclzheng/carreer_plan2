import { defineStore } from 'pinia';
import type { CareerPlan, CareerDirection } from '@/types';

export const useCareerPlanningStore = defineStore('careerPlanning', {
  state: () => ({
    careerDirections: [
      {
        id: 1,
        title: '前端开发工程师',
        recommendedSkills: [
          { name: 'HTML/CSS', semesterGoal: '熟练掌握' },
          { name: 'JavaScript', semesterGoal: '深入学习' },
          { name: 'React', semesterGoal: '项目实践' }
        ],
        recommendedCourses: [
          { name: 'Web前端开发', semester: '大二上' },
          { name: '前端框架', semester: '大二下' }
        ],
        recommendedCertificates: [
          { name: 'Web前端开发证书', semester: '大三上' }
        ]
      },
      {
        id: 2,
        title: '后端开发工程师',
        recommendedSkills: [
          { name: 'Java', semesterGoal: '深入学习' },
          { name: 'Spring Boot', semesterGoal: '项目实践' },
          { name: '数据库', semesterGoal: '精通' }
        ],
        recommendedCourses: [
          { name: 'Java程序设计', semester: '大二上' },
          { name: '数据库系统', semester: '大二下' }
        ],
        recommendedCertificates: [
          { name: 'Java开发认证', semester: '大三上' }
        ]
      }
    ],
    personalizedPlan: null as CareerPlan | null
  }),

  actions: {
    // 生成个性化职业规划
    generatePersonalizedPlan(selectedCareer: number) {
      const career = this.careerDirections.find(c => c.id === selectedCareer);
      
      if (!career) {
        throw new Error('未找到选定的职业方向');
      }

      const plan: CareerPlan = {
        targetCareer: career.title,
        semesters: [
          {
            semester: '大二上',
            skills: career.recommendedSkills.slice(0, 1).map(skill => ({
              ...skill,
              status: '进行中'
            })),
            courses: career.recommendedCourses.slice(0, 1),
            certificates: []
          },
          {
            semester: '大二下',
            skills: career.recommendedSkills.slice(1, 2).map(skill => ({
              ...skill,
              status: '未开始'
            })),
            courses: career.recommendedCourses.slice(1),
            certificates: []
          },
          {
            semester: '大三上',
            skills: career.recommendedSkills.slice(2).map(skill => ({
              ...skill,
              status: '未开始'
            })),
            courses: [],
            certificates: career.recommendedCertificates
          }
        ]
      };

      this.personalizedPlan = plan;
      return plan;
    },

    // 更新技能状态
    updateSkillStatus(semesterIndex: number, skillIndex: number, newStatus: string) {
      if (this.personalizedPlan) {
        this.personalizedPlan.semesters[semesterIndex].skills[skillIndex].status = newStatus;
      }
    }
  }
});
