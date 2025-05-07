<template>
  <div id="app" class="min-h-screen flex">
    <!-- 侧边栏 -->
    <Sidebar v-if="isAuthenticated" />
    
    <!-- 主内容区 -->
    <main class="flex-1 overflow-y-auto">
      <!-- 顶部导航 -->
      <Header v-if="isAuthenticated" />
      
      <!-- 路由视图 -->
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import Sidebar from '@/components/layout/Sidebar.vue'
import Header from '@/components/layout/Header.vue'

const authStore = useAuthStore()

// 是否已认证
const isAuthenticated = computed(() => !!authStore.user)
</script>
