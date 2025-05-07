<template>
  <aside class="w-64 bg-gray-800 text-white p-4">
    <h2 class="text-xl font-bold mb-6">职业规划平台</h2>
    <nav>
      <router-link 
        v-for="item in menuItems" 
        :key="item.name"
        :to="item.path"
        class="block py-2 px-4 hover:bg-gray-700 rounded transition"
        active-class="bg-gray-700"
      >
        <component :is="item.icon" class="inline-block mr-2 w-5 h-5" />
        {{ item.label }}
      </router-link>
    </nav>
  </aside>
</template>

<script setup lang="ts">
import { 
  LayoutDashboard, 
  Search, 
  BookOpen, 
  FileText, 
  Star, 
  Clock 
} from 'lucide-vue-next'

const menuItems = [
  { 
    name: 'Dashboard', 
    path: '/dashboard', 
    icon: LayoutDashboard,
    label: '仪表盘' 
  },
  { 
    name: 'CareerSearch', 
    path: '/career-search', 
    icon: Search,
    label: '职业搜索' 
  },
  { 
    name: 'AcademicPerformance', 
    path: '/academic-performance', 
    icon: BookOpen,
    label: '成绩管理' 
  },
  { 
    name: 'CertificateManagement', 
    path: '/certificates', 
    icon: FileText,
    label: '证书管理' 
  },
  { 
    name: 'TaskTracking', 
    path: '/tasks', 
    icon: Clock,
    label: '任务追踪' 
  },
  { 
    name: 'PersonalizedCareerPlanning', 
    path: '/career-planning', 
    icon: Star,
    label: '职业规划' 
  }
]
</script>
