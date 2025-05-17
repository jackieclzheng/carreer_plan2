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
// import AdminUsersView from '@/views/AdminUsersView.vue'
// import AdminDashboardView from '@/views/AdminDashboardView.vue'
// import AdminCareerDirectionsView from '@/views/AdminCareerDirectionsView.vue'

// 导入布局组件
import AdminLayout from '@/layouts/AdminLayout.vue'

// 导入管理员组件
import AdminDashboardView from '@/views/AdminDashboardView.vue'
import AdminUsersView from '@/views/AdminUsersView.vue'
import AdminCareerDirectionsView from '@/views/AdminCareerDirectionsView.vue'
import AdminAnnouncementsView from '@/views/AdminAnnouncementsView.vue'
import AdminCareerIntroView from '@/views/AdminCareerIntroView.vue'
import AdminCareersView from '@/views/AdminCareersView.vue'
import AdminGradesView from '@/views/AdminGradesView.vue'
import AdminTasksView from '@/views/AdminTasksView.vue'

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
  },
  // 添加这个路由
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('@/views/AdminLoginView.vue'),
    meta: { requiresGuest: true }  // 只有未登录的用户才能访问
  },

  // 管理员路由组
  // {
  //   path: '/admin',
  //   name: 'Admin',
  //   component: () => import('@/layouts/AdminLayout.vue'),
  //   meta: { requiresAuth: true, requiresAdmin: true },
  //   children: [
  //     {
  //       path: '',
  //       name: 'AdminDashboard',
  //       component: AdminDashboardView
  //     },
  //     {
  //       path: 'users',
  //       name: 'AdminUsers',
  //       component: AdminUsersView
  //     },
  //     {
  //       path: 'career-directions',
  //       name: 'AdminCareerDirections',
  //       component: AdminCareerDirectionsView
  //     }
  //   ]
  // }

  // router/index.ts
  // 管理员路由组
  {
    path: '/admin',
    component: AdminLayout,
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: AdminDashboardView
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: AdminUsersView
      },
      {
        path: 'career-directions',
        name: 'AdminCareerDirections',
        component: AdminCareerDirectionsView
      },
      // 添加缺少的路由
      {
        path: 'announcements',
        name: 'AdminAnnouncements',
        component: AdminAnnouncementsView
      },
      {
        path: 'career-intro',
        name: 'AdminCareerIntro',
        component: AdminCareerIntroView
      },
      {
        path: 'careers',
        name: 'AdminCareers',
        component: AdminCareersView
      },
      {
        path: 'grades',
        name: 'AdminGrades',
        component: AdminGradesView
      },
      {
        path: 'tasks',
        name: 'AdminTasks',
        component: AdminTasksView
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 导航守卫
// router.beforeEach((to, from, next) => {
//   const authStore = useAuthStore();
  
//   if (to.meta.requiresAuth && !authStore.isAuthenticated) {
//     next('/login');
//   } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
//     next('/dashboard');
//   } else {
//     next();
//   }
// });
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();
  
  if (to.meta.requiresGuest && authStore.isAuthenticated) {
    // 已登录用户访问游客页面（如登录页）时重定向
    next(authStore.isAdmin ? '/admin' : '/dashboard');
  } else if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // 未登录用户访问需要认证的页面时重定向到登录页
    next('/login');
  } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
    // 非管理员用户访问管理员页面时重定向到用户仪表盘
    next('/dashboard');
  } else {
    next();
  }
});

export default router
