import { defineStore } from 'pinia';
import type { Career } from '@/types';

export const useCareerSearchStore = defineStore('careerSearch', {
  state: () => ({
    careers: [
      {
        id: 1,
        title: '前端开发工程师',
        description: '负责网站和web应用程序的用户界面开发',
        requiredSkills: ['JavaScript', 'React', 'Vue', 'HTML/CSS'],
        averageSalary: '15-30K'
      },
      {
        id: 2,
        title: '后端开发工程师',
        description: '负责服务器端应用程序和系统架构开发',
        requiredSkills: ['Java', 'Spring Boot', 'MySQL', 'Redis'],
        averageSalary: '20-40K'
      },
      {
        id: 3,
        title: '全栈开发工程师',
        description: '同时掌握前端和后端技术的全面开发者',
        requiredSkills: ['JavaScript', 'Node.js', 'React', 'MongoDB'],
        averageSalary: '25-45K'
      }
    ],
    searchTerm: ''
  }),

  getters: {
    filteredCareers(): Career[] {
      if (!this.searchTerm) return this.careers;
      
      return this.careers.filter(career => 
        career.title.includes(this.searchTerm) || 
        career.description.includes(this.searchTerm) ||
        career.requiredSkills.some(skill => skill.includes(this.searchTerm))
      );
    }
  },

  actions: {
    setSearchTerm(term: string) {
      this.searchTerm = term;
    }
  }
});
