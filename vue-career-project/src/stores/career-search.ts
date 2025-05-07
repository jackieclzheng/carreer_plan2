import { defineStore } from 'pinia';

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
    async searchCareers(term: string, page = 1) {
      try {
        this.loading = true;
        this.error = null;
        this.searchTerm = term;
        this.currentPage = page;

        const response = await fetch(
          `/api/careers/search?q=${encodeURIComponent(term)}&page=${page}&pageSize=${this.pageSize}`
        );

        if (!response.ok) {
          throw new Error('搜索失败');
        }

        const data = await response.json();
        this.careers = data.careers;
        this.totalResults = data.total;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '搜索失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 获取职业详情
    async getCareerDetails(id: number) {
      try {
        this.loading = true;
        this.error = null;

        const response = await fetch(`/api/careers/${id}`);
        
        if (!response.ok) {
          throw new Error('获取职业详情失败');
        }

        return await response.json();
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取职业详情失败';
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

        const response = await fetch('/api/careers/recommended');
        
        if (!response.ok) {
          throw new Error('获取推荐职业失败');
        }

        const data = await response.json();
        return data.careers;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取推荐职业失败';
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

        const response = await fetch('/api/careers/saved', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ careerId })
        });

        if (!response.ok) {
          throw new Error('保存职业失败');
        }

        return await response.json();
      } catch (error) {
        this.error = error instanceof Error ? error.message : '保存职业失败';
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

        const response = await fetch(`/api/careers/saved/${careerId}`, {
          method: 'DELETE'
        });

        if (!response.ok) {
          throw new Error('取消收藏失败');
        }
      } catch (error) {
        this.error = error instanceof Error ? error.message : '取消收藏失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
