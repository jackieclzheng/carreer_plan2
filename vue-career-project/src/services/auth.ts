// src/stores/auth.ts
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
    isAuthenticated: false,
    isAdmin: false
  }),
  
  actions: {
    // 接受用户名和密码作为参数的通用登录方法
    async login(username: string, password: string) {
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
    },
    
    logout() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      this.isAdmin = false
    }
  }
})