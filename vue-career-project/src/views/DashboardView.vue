<template>
  <div class="p-6">
    <!-- 加载状态 -->
    <div v-if="loading" class="flex justify-center items-center h-64">
      <div class="text-gray-500">加载中...</div>
    </div>

    <!-- 错误提示 -->
    <div v-else-if="error" class="flex justify-center items-center h-64">
      <div class="text-red-500">{{ error }}</div>
    </div>

    <!-- 仪表盘内容 -->
    <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- 总体进度卡片 -->
      <Card class="md:col-span-2">
        <CardHeader>
          <CardTitle>职业发展总览</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="flex items-center space-x-4">
            <div class="w-full">
              <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-medium">整体进度</span>
                <span class="text-sm font-bold">{{ dashboardStore.overallProgress }}%</span>
              </div>
              <Progress :value="dashboardStore.overallProgress" />
              <p class="mt-2 text-sm text-gray-600">
                当前目标：{{ dashboardStore.currentGoal }}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- 关键指标 -->
      <Card>
        <CardHeader>
          <CardTitle>关键指标</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="space-y-4">
            <div 
              v-for="metric in dashboardStore.keyMetrics" 
              :key="metric.title" 
              class="flex items-center space-x-4 bg-gray-50 p-3 rounded-lg"
            >
              <div :class="`p-2 rounded-full ${metric.color}`">
                <component 
                  :is="getIconComponent(metric.icon)" 
                  class="h-5 w-5" 
                />
              </div>
              <div>
                <p class="text-sm text-gray-600">{{ metric.title }}</p>
                <p class="text-lg font-bold">{{ metric.value }}</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- 技能进度 -->
      <Card class="md:col-span-2">
        <CardHeader>
          <CardTitle>技能进度</CardTitle>
        </CardHeader>
        <CardContent>
          <div 
            v-for="skill in dashboardStore.skillProgress" 
            :key="skill.name" 
            class="mb-4"
          >
            <div class="flex justify-between items-center mb-1">
              <span class="text-sm">{{ skill.name }}</span>
              <span class="text-sm font-bold">{{ skill.progress }}%</span>
            </div>
            <Progress :value="skill.progress" />
          </div>
        </CardContent>
      </Card>

      <!-- 最近活动 -->
      <Card>
        <CardHeader>
          <CardTitle>最近活动</CardTitle>
        </CardHeader>
        <CardContent>
          <div 
            v-for="activity in dashboardStore.recentActivities" 
            :key="activity.title" 
            class="flex items-center space-x-3 p-3 border-b last:border-b-0"
          >
            <div class="flex-shrink-0">
              <div :class="`
                w-10 h-10 rounded-full flex items-center justify-center
                ${getActivityColor(activity.type)}
              `">
                <component 
                  :is="getActivityIcon(activity.type)" 
                  class="h-5 w-5" 
                />
              </div>
            </div>
            <div class="flex-1">
              <p class="text-sm font-medium">{{ activity.title }}</p>
              <p class="text-xs text-gray-500">{{ activity.date }}</p>
            </div>
            <span :class="`
              text-xs px-2 py-1 rounded
              ${getActivityColor(activity.type)}
            `">
              {{ activity.type }}
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useDashboardStore } from '@/stores/dashboard';
import { Book, Trophy, Star } from 'lucide-vue-next';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';

const dashboardStore = useDashboardStore();
const loading = ref(true);
const error = ref('');

// 获取仪表盘数据
const fetchDashboardData = async () => {
  try {
    loading.value = true;
    await dashboardStore.fetchDashboardData();
  } catch (e) {
    error.value = '获取数据失败，请刷新重试';
  } finally {
    loading.value = false;
  }
};

// 组件挂载时获取数据
onMounted(() => {
  fetchDashboardData();
});

// 获取活动图标
const getActivityIcon = (type: string) => {
  switch(type) {
    case '学习': return Book;
    case '认证': return Trophy;
    case '竞赛': return Star;
    default: return Book;
  }
};

// 获取活动颜色
const getActivityColor = (type: string) => {
  switch(type) {
    case '学习': return 'bg-blue-100 text-blue-600';
    case '认证': return 'bg-green-100 text-green-600';
    case '竞赛': return 'bg-purple-100 text-purple-600';
    default: return 'bg-gray-100 text-gray-600';
  }
};

// 获取指标图标组件
const getIconComponent = (iconName: string) => {
  switch(iconName) {
    case 'book': return Book;
    case 'trophy': return Trophy;
    case 'star': return Star;
    default: return Book;
  }
};
</script>
