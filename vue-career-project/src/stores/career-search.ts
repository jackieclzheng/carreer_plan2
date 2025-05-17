// src/stores/career-search.ts
import { defineStore } from 'pinia';
import { apiService } from '@/services/api';
import axios from 'axios'; // 导入 axios 用于类型检查

interface Career {
  id: number;
  title: string;
  description: string;
  requirements: string[];
  salary: string;
  company: string;
}

export const useCareerSearchStore = defineStore('careerSearch', {
  state: () => ({
    careers: [] as Career[],
    searchTerm: '',
    loading: false,
    error: null as string | null,
    totalResults: 0,
    currentPage: 1,
    pageSize: 10
  }),

  actions: {
    // 搜索职业
    // async searchCareers(term: string, page = 1) {
    //   try {
    //     this.loading = true;
    //     this.error = null;
    //     this.searchTerm = term;
    //     this.currentPage = page;

    //     const { data } = await apiService.get('/careers/search', {
    //       params: {
    //         q: term,
    //         page: page,
    //         pageSize: this.pageSize
    //       }
    //     });

    //     this.careers = data.careers;
    //     this.totalResults = data.total;
    //   } catch (error) {
    //     console.error('搜索职业失败:', error);
    //     this.error = axios.isAxiosError(error)
    //       ? error.message || '搜索失败'
    //       : '搜索失败';
    //     throw error;
    //   } finally {
    //     this.loading = false;
    //   }
    // },

    // 检查store中的方法是否正确使用传入的term参数
    async searchCareers(term: string, page = 1) {
      try {
        this.loading = true;
        this.error = null;
        this.searchTerm = term;  // 保存到store中
        this.currentPage = page;

        // 调试日志
        console.log('Store接收到的搜索词:', term);

        // 如果使用fetch，确保正确传入term参数
        const response = await fetch(
          `/api/careers/search?q=${encodeURIComponent(term)}&page=${page}&pageSize=${this.pageSize}`
        );

        // 或者如果使用axios/apiService，确保正确传入params
        // const { data } = await apiService.get('/api/careers/search', {
        //   params: {
        //     q: term,  // 这里使用传入的term
        //     page,
        //     pageSize: this.pageSize
        //   }
        // });

        // 处理响应...
      } catch (error) {
        // 错误处理...
      } finally {
        this.loading = false;
      }
    },

    // 获取职业详情
    async getCareerDetails(id: number) {
      try {
        this.loading = true;
        this.error = null;

        const { data } = await apiService.get(`/api/careers/${id}`);
        return data;
      } catch (error) {
        console.error('获取职业详情失败:', error);
        this.error = axios.isAxiosError(error)
          ? error.message || '获取职业详情失败'
          : '获取职业详情失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 获取推荐职业
    async getRecommendedCareers() {
      try {
        this.loading = true;
        this.error = null;

        const { data } = await apiService.get('/api/careers/recommended');
        return data.careers;
      } catch (error) {
        console.error('获取推荐职业失败:', error);
        this.error = axios.isAxiosError(error)
          ? error.message || '获取推荐职业失败'
          : '获取推荐职业失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 保存职业收藏
    async saveCareer(careerId: number) {
      try {
        this.loading = true;
        this.error = null;

        const { data } = await apiService.post('/api/careers/saved', { careerId });
        return data;
      } catch (error) {
        console.error('保存职业失败:', error);
        this.error = axios.isAxiosError(error)
          ? error.message || '保存职业失败'
          : '保存职业失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 取消收藏
    async unsaveCareer(careerId: number) {
      try {
        this.loading = true;
        this.error = null;

        await apiService.delete(`/api/careers/saved/${careerId}`);
      } catch (error) {
        console.error('取消收藏失败:', error);
        this.error = axios.isAxiosError(error)
          ? error.message || '取消收藏失败'
          : '取消收藏失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});