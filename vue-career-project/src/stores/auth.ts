import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
    isAuthenticated: false
  }),
  
  actions: {
    login(credentials) {
      // 简化版登录逻辑，仅用于演示
      this.user = {
        id: 1,
        username: 'demo_user',
        email: 'demo@example.com'
      }
      this.token = 'demo_token'
      this.isAuthenticated = true
    },
    
    logout() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
    }
  }
})
