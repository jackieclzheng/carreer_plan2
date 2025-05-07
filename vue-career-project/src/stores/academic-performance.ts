import { defineStore } from 'pinia';
import type { Course } from '@/types';

export const useAcademicPerformanceStore = defineStore('academicPerformance', {
  state: () => ({
    courses: [] as Course[],
    loading: false,
    error: null as string | null
  }),

  getters: {
    totalCredits(): number {
      return this.courses.reduce((sum, course) => sum + course.credits, 0);
    },
    calculateGPA() {
      if (this.courses.length === 0) return 0;
      
      const totalWeightedScore = this.courses.reduce((sum, course) => {
        let gradePoint = 0;
        if (course.score >= 90) gradePoint = 4.0;
        else if (course.score >= 85) gradePoint = 3.7;
        else if (course.score >= 80) gradePoint = 3.3;
        else if (course.score >= 75) gradePoint = 3.0;
        else if (course.score >= 70) gradePoint = 2.7;
        else if (course.score >= 65) gradePoint = 2.3;
        else if (course.score >= 60) gradePoint = 2.0;
        else gradePoint = 0;

        return sum + (gradePoint * course.credits);
      }, 0);

      return Number((totalWeightedScore / this.totalCredits).toFixed(2));
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
    // 获取所有课程成绩
    async fetchCourses() {
      try {
        this.loading = true;
        const response = await fetch('/api/courses');
        if (!response.ok) throw new Error('获取课程失败');
        
        const data = await response.json();
        this.courses = data;
      } catch (error) {
        this.error = '获取课程数据失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新课程成绩
    async updateCourseScore(courseId: number, newScore: number) {
      try {
        this.loading = true;
        const response = await fetch(`/api/courses/${courseId}/score`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ score: newScore }),
        });

        if (!response.ok) throw new Error('更新成绩失败');
        
        const updatedCourse = await response.json();
        const index = this.courses.findIndex(c => c.id === courseId);
        if (index !== -1) {
          this.courses[index] = updatedCourse;
        }
      } catch (error) {
        this.error = '更新成绩失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 添加新课程
    async addCourse(course: Omit<Course, 'id'>) {
      try {
        this.loading = true;
        const response = await fetch('/api/courses', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(course),
        });

        if (!response.ok) throw new Error('添加课程失败');
        
        const newCourse = await response.json();
        this.courses.push(newCourse);
      } catch (error) {
        this.error = '添加课程失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
