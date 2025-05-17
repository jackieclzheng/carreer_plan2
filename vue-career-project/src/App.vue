<template>
  <div id="app" class="min-h-screen">
    <!-- 未认证状态只显示路由视图（登录页） -->
    <template v-if="!isAuthenticated">
      <router-view />
    </template>
    
    <!-- 已认证状态，区分前台和管理后台 -->
    <template v-else>
      <!-- 管理后台路由 - 只显示路由视图，让 AdminLayout 处理布局 -->
      <template v-if="isAdminRoute">
        <router-view />
      </template>
      
      <!-- 前台路由 - 显示前台布局 -->
      <template v-else>
        <div class="flex">
          <Sidebar />
          <div class="flex-1 flex flex-col">
            <Header />
            <main class="p-6 flex-1 overflow-y-auto">
              <router-view />
            </main>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import Sidebar from '@/components/layout/Sidebar.vue';
import Header from '@/components/layout/Header.vue';

const route = useRoute();
const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated);

// 判断当前是否为管理后台路由
const isAdminRoute = computed(() => {
  return route.path.startsWith('/admin');
});

// 为调试添加路由和认证状态监听
watch(() => route.path, (newPath) => {
  console.log('路由变化:', {
    新路径: newPath,
    认证状态: isAuthenticated.value,
    是否管理后台: isAdminRoute.value
  });
});
</script>