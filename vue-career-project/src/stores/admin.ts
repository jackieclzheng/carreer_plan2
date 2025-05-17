import { defineStore } from 'pinia';
import { apiService } from '@/services/api';

export const useAdminStore = defineStore('admin', {
  state: () => ({
    users: [],
    loading: false,
    error: null as string | null
  }),

  actions: {
    async fetchUsers() {
      try {
        this.loading = true;
        const { data } = await apiService.get('/admin/users');
        this.users = data;
      } catch (error) {
        console.error('获取用户列表失败:', error);
        this.error = error instanceof Error ? error.message : '获取用户失败';
      } finally {
        this.loading = false;
      }
    },

    async fetchDashboardStats() {
      try {
        this.loading = true;
        const { data } = await apiService.get('/admin/dashboard/stats');
        return data;
      } catch (error) {
        console.error('获取仪表盘数据失败:', error);
        this.error = error instanceof Error ? error.message : '获取数据失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async fetchCareerDirections() {
      try {
        this.loading = true;
        const { data } = await apiService.get('/admin/career-directions');
        return data;
      } catch (error) {
        console.error('获取职业方向列表失败:', error);
        this.error = error instanceof Error ? error.message : '获取数据失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async deleteCareerDirection(id: number) {
      try {
        this.loading = true;
        await apiService.delete(`/admin/career-directions/${id}`);
      } catch (error) {
        console.error('删除职业方向失败:', error);
        this.error = error instanceof Error ? error.message : '删除失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }

    // ...其他管理员操作方法
  }
});
