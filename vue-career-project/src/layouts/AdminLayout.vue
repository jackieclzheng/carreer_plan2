<template>
  <div class="flex h-screen bg-gray-100">
    <!-- 侧边栏 -->
    <aside class="w-64 bg-white shadow-md">
      <div class="p-4">
        <h1 class="text-xl font-semibold text-gray-800">后台管理</h1>
      </div>
      <nav class="mt-4">
        <router-link 
          to="/admin" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          exact-active-class="bg-blue-50 text-blue-600"
        >
          <LayoutDashboard class="w-5 h-5 mr-2" />
          管理首页
        </router-link>
        
        <router-link 
          to="/admin/users" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <Users class="w-5 h-5 mr-2" />
          用户管理
        </router-link>
        
        <router-link 
          to="/admin/career-directions" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <Briefcase class="w-5 h-5 mr-2" />
          职业方向管理
        </router-link>
        
        <!-- 添加缺少的管理页面导航 -->
        <router-link 
          to="/admin/announcements" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <Bell class="w-5 h-5 mr-2" />
          公告管理
        </router-link>
        
        <router-link 
          to="/admin/career-intro" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <FileText class="w-5 h-5 mr-2" />
          职业介绍管理
        </router-link>
        
        <router-link 
          to="/admin/careers" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <Briefcase class="w-5 h-5 mr-2" />
          职业管理
        </router-link>
        
        <router-link 
          to="/admin/grades" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <GraduationCap class="w-5 h-5 mr-2" />
          成绩管理
        </router-link>
        
        <router-link 
          to="/admin/tasks" 
          class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
          active-class="bg-blue-50 text-blue-600"
        >
          <CheckSquare class="w-5 h-5 mr-2" />
          任务管理
        </router-link>
      </nav>
    </aside>

    <!-- 主内容区 -->
    <main class="flex-1 p-8 overflow-auto">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup lang="ts">
import { 
  LayoutDashboard, 
  Users, 
  Briefcase, 
  Bell, 
  FileText, 
  GraduationCap,
  CheckSquare
} from 'lucide-vue-next';
</script>