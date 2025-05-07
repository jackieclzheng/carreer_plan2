import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

// 页面组件
import AuthView from '@/views/AuthView.vue'
import DashboardView from '@/views/DashboardView.vue'
import CareerSearchView from '@/views/CareerSearchView.vue'
import AcademicPerformanceView from '@/views/AcademicPerformanceView.vue'
import CertificateManagementView from '@/views/CertificateManagementView.vue'
import TaskTrackingView from '@/views/TaskTrackingView.vue'
import PersonalizedCareerPlanningView from '@/views/PersonalizedCareerPlanningView.vue'

// 路由配置
const routes: Array<RouteRecordRaw> = [
  {
    path: '/login',
    name: 'Login',
    component: AuthView,
    meta: { requiresGuest: true }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: DashboardView,
    meta: { requiresAuth: true }
  },
  {
    path: '/career-search',
    name: 'CareerSearch',
    component: CareerSearchView,
    meta: { requiresAuth: true }
  },
  {
    path: '/academic-performance',
    name: 'AcademicPerformance',
    component: AcademicPerformanceView,
    meta: { requiresAuth: true }
  },
  {
    path: '/certificates',
    name: 'CertificateManagement',
    component: CertificateManagementView,
    meta: { requiresAuth: true }
  },
  {
    path: '/tasks',
    name: 'TaskTracking',
    component: TaskTrackingView,
    meta: { requiresAuth: true }
  },
  {
    path: '/career-planning',
    name: 'PersonalizedCareerPlanning',
    component: PersonalizedCareerPlanningView,
    meta: { requiresAuth: true }
  },
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 导航守卫
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const isAuthenticated = !!authStore.user

  if (to.meta.requiresAuth && !isAuthenticated) {
    // 未认证用户重定向到登录页
    next('/login')
  } else if (to.meta.requiresGuest && isAuthenticated) {
    // 已认证用户访问登录页重定向到仪表盘
    next('/dashboard')
  } else {
    next()
  }
})

export default router
