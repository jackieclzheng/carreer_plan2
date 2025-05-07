import { defineStore } from 'pinia';
import type { Course } from '@/types';

export const useAcademicPerformanceStore = defineStore('academicPerformance', {
  state: () => ({
    courses: [
      { id: 1, name: '数据结构', semester: '2023春', score: 92, credits: 4 },
      { id: 2, name: '操作系统', semester: '2023春', score: 88, credits: 3 },
      { id: 3, name: '计算机网络', semester: '2023秋', score: 95, credits: 4 },
      { id: 4, name: '数据库系统', semester: '2023秋', score: 90, credits: 3 }
    ]
  }),

  getters: {
    totalCredits(): number {
      return this.courses.reduce((sum, course) => sum + course.credits, 0);
    },
    calculateGPA(): number {
      const totalCreditsScore = this.courses.reduce(
        (sum, course) => sum + course.score * course.credits, 
        0
      );
      return Number((totalCreditsScore / this.totalCredits).toFixed(2));
    },

    coursesBySemester(): Record<string, Course[]> {
      return this.courses.reduce((acc, course) => {
        if (!acc[course.semester]) {
          acc[course.semester] = [];
        }
        acc[course.semester].push(course);
        return acc;
      }, {} as Record<string, Course[]>);
    }
  },

  actions: {
    // 添加课程
    addCourse(course: Course) {
      this.courses.push({
        ...course,
        id: this.courses.length + 1
      });
    },

    // 更新课程成绩
    updateCourseScore(id: number, newScore: number) {
      const courseIndex = this.courses.findIndex(course => course.id === id);
      if (courseIndex !== -1) {
        this.courses[courseIndex].score = newScore;
      }
    }
  }
});
