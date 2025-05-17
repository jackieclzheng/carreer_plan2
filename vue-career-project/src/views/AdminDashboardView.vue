<template>
  <div>
    <h2 class="text-2xl font-semibold mb-6">管理员仪表盘</h2>
    
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- 用户统计卡片 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-2">用户统计</h3>
        <div class="flex justify-between items-center">
          <Users class="w-8 h-8 text-blue-500" />
          <span class="text-3xl font-bold">{{ stats.totalUsers }}</span>
        </div>
        <p class="text-sm text-gray-500 mt-2">总用户数量</p>
      </div>

      <!-- 活跃用户卡片 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-2">活跃用户</h3>
        <div class="flex justify-between items-center">
          <Activity class="w-8 h-8 text-green-500" />
          <span class="text-3xl font-bold">{{ stats.activeUsers }}</span>
        </div>
        <p class="text-sm text-gray-500 mt-2">最近7天活跃用户</p>
      </div>

      <!-- 系统状态卡片 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-2">系统状态</h3>
        <div class="flex justify-between items-center">
          <Server class="w-8 h-8 text-purple-500" />
          <Badge :variant="stats.systemStatus === 'normal' ? 'success' : 'destructive'">
            {{ stats.systemStatus === 'normal' ? '运行正常' : '需要注意' }}
          </Badge>
        </div>
        <p class="text-sm text-gray-500 mt-2">当前系统状态</p>
      </div>
    </div>

    <!-- 最近活动列表 -->
    <div class="mt-8 bg-white rounded-lg shadow">
      <div class="p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">最近活动</h3>
        <div class="space-y-4">
          <div v-for="activity in recentActivities" :key="activity.id" class="flex items-start">
            <div class="flex-shrink-0">
              <ActivityIcon class="w-5 h-5 text-gray-400" />
            </div>
            <div class="ml-3">
              <p class="text-sm text-gray-900">{{ activity.description }}</p>
              <p class="text-xs text-gray-500">{{ activity.time }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { Users, Activity, Server, ActivityIcon } from 'lucide-vue-next';
import { useAdminStore } from '@/stores/admin';
import { Badge } from '@/components/ui/badge';

const adminStore = useAdminStore();

// 统计数据
const stats = ref({
  totalUsers: 0,
  activeUsers: 0,
  systemStatus: 'normal'
});

// 最近活动数据
const recentActivities = ref([]);

// 初始化数据
onMounted(async () => {
  try {
    const dashboardData = await adminStore.fetchDashboardStats();
    stats.value = dashboardData.stats;
    recentActivities.value = dashboardData.recentActivities;
  } catch (error) {
    console.error('获取仪表盘数据失败:', error);
  }
});
</script>
