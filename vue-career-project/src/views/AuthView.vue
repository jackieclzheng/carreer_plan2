<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="max-w-md w-full p-6 bg-white rounded-lg shadow-md">
      <h1 class="text-2xl font-bold text-center mb-6">登录</h1>
      
      <form @submit.prevent="handleLogin">
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="username">
            用户名
          </label>
          <input 
            id="username"
            v-model="username" 
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" 
            type="text" 
            placeholder="请输入用户名"
          >
        </div>
        
        <div class="mb-6">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="password">
            密码
          </label>
          <input 
            id="password"
            v-model="password" 
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" 
            type="password" 
            placeholder="请输入密码"
          >
        </div>
        
        <div v-if="errorMessage" class="mb-4 text-red-500 text-sm">
          {{ errorMessage }}
        </div>
        
        <div class="flex items-center justify-between">
          <button 
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            type="submit"
            :disabled="loading"
          >
            {{ loading ? '登录中...' : '登录' }}
          </button>
          <a class="inline-block align-baseline font-bold text-sm text-blue-500 hover:text-blue-800" href="#">
            忘记密码?
          </a>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const username = ref('')
const password = ref('')
const loading = ref(false)
const errorMessage = ref('')

const handleLogin = async () => {
  try {
    if (!username.value || !password.value) {
      errorMessage.value = '请输入用户名和密码'
      return
    }

    loading.value = true
    await authStore.login({
      username: username.value,
      password: password.value
    })
    
    router.push('/dashboard')
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : '登录失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>
