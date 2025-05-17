// src/stores/auth.ts
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => {
    // 尝试从 localStorage 恢复状态
    const savedAuth = localStorage.getItem('auth');
    if (savedAuth) {
      try {
        return JSON.parse(savedAuth);
      } catch (e) {
        console.error('Failed to parse saved auth state', e);
      }
    }
    
    // 默认状态
    return {
      user: null,
      token: null,
      isAuthenticated: false,
      isAdmin: false
    };
  },
  
  actions: {
    // 接受用户名和密码作为参数的通用登录方法
    async login(username: string, password: string) {
      console.log('Login attempt:', username);
      
      // 在这里检查是否是管理员账号
      if (username === 'admin' && password === 'admin123') {
        this.user = {
          id: 999,
          username: username,
          role: 'admin'
        }
        this.token = 'admin_token'
        this.isAuthenticated = true
        this.isAdmin = true
      } else {
        // 普通用户登录
        this.user = {
          id: 1,
          username: username,
          role: 'user'
        }
        this.token = 'user_token'
        this.isAuthenticated = true
        this.isAdmin = false
      }
      
      // 保存状态到 localStorage
      this.persistState();
      console.log('Login successful, state updated:', { 
        isAuthenticated: this.isAuthenticated, 
        isAdmin: this.isAdmin 
      });
    },
    
    logout() {
      console.log('Logging out');
      this.user = null
      this.token = null
      this.isAuthenticated = false
      this.isAdmin = false
      
      // 清除 localStorage
      localStorage.removeItem('auth');
    },
    
    // 新增：持久化状态方法
    persistState() {
      localStorage.setItem('auth', JSON.stringify({
        user: this.user,
        token: this.token,
        isAuthenticated: this.isAuthenticated,
        isAdmin: this.isAdmin
      }));
    }
  }
})