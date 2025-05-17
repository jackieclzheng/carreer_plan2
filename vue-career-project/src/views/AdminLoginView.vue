<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-8 rounded-lg shadow-md w-96">
      <h2 class="text-2xl font-semibold text-center mb-6">管理员登录</h2>
      
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700">用户名</label>
          <input
            v-model="username"
            type="text"
            required
            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            placeholder="请输入管理员用户名"
          />
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700">密码</label>
          <input
            v-model="password"
            type="password"
            required
            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            placeholder="请输入管理员密码"
          />
        </div>

        <div v-if="error" class="text-red-500 text-sm">
          {{ error }}
        </div>
        
        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600"
        >
          {{ loading ? '登录中...' : '管理员登录' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const authStore = useAuthStore();

const username = ref('');
const password = ref('');
const error = ref('');
const loading = ref(false);

// 添加组件挂载时的日志
onMounted(() => {
  console.log('AdminLoginView mounted, auth state:', { 
    isAuthenticated: authStore.isAuthenticated, 
    isAdmin: authStore.isAdmin 
  });
  
  // 如果已经是认证的管理员，直接跳转到管理页面
  if (authStore.isAuthenticated && authStore.isAdmin) {
    console.log('Already authenticated as admin, redirecting to admin dashboard');
    router.push('/admin');
  }
});

// const handleLogin = async () => {
//   try {
//     loading.value = true;
//     error.value = '';
    
//     console.log('Admin login attempt:', username.value);
//     await authStore.login(username.value, password.value);
    
//     console.log('Login completed, auth state:', { 
//       isAuthenticated: authStore.isAuthenticated, 
//       isAdmin: authStore.isAdmin 
//     });
    
//     if (authStore.isAdmin) {
      
//       // 在这里添加标志
//       localStorage.setItem('isAdmin', 'true');

//       console.log('User is admin, navigating to admin dashboard');

//       router.push('/admin');
      
//       // 为防止状态丢失，确保状态被持久化
//       if (typeof authStore.persistState === 'function') {
//         authStore.persistState();
//       } else {
//         // 如果 AuthStore 中没有 persistState 方法，手动保存
//         localStorage.setItem('auth', JSON.stringify({
//           user: authStore.user,
//           token: authStore.token,
//           isAuthenticated: authStore.isAuthenticated,
//           isAdmin: authStore.isAdmin
//         }));
//       }
      
//       // 使用 nextTick 确保状态更新后再导航
//       await router.push('/admin');
//     } else {
//       console.log('User is not admin, showing error');
//       error.value = '无管理员权限';
//       // 清除非管理员的登录状态
//       authStore.logout();
//     }
//   } catch (e) {
//     console.error('Login error:', e);
//     error.value = '登录失败，请检查用户名和密码';
//   } finally {
//     loading.value = false;
//   }
// };

const handleLogin = async () => {
  try {
    loading.value = true;
    error.value = '';
    
    console.log('Admin login attempt:', username.value);
    await authStore.login(username.value, password.value);
    
    console.log('Login completed, auth state:', {
      isAuthenticated: authStore.isAuthenticated,
      isAdmin: authStore.isAdmin
    });
    
    if (authStore.isAdmin) {
      console.log('User is admin, setting admin flag');
      
      // 在这里添加标志
      localStorage.setItem('isAdmin', 'true');
      
      // 为防止状态丢失，确保状态被持久化
      if (typeof authStore.persistState === 'function') {
        console.log('Using store persistState method');
        authStore.persistState();
      } else {
        console.log('Manually persisting auth state');
        // 如果 AuthStore 中没有 persistState 方法，手动保存
        try {
          const stateToSave = {
            user: authStore.user,
            token: authStore.token,
            isAuthenticated: authStore.isAuthenticated,
            isAdmin: authStore.isAdmin
          };
          localStorage.setItem('auth', JSON.stringify(stateToSave));
        } catch (error) {
          console.error('Error saving auth state to localStorage:', error);
          // 即使持久化失败，也继续导航
        }
      }
      
      console.log('Navigating to admin dashboard');
      await router.push('/admin');
    } else {
      console.log('User is not admin, showing error');
      error.value = '无管理员权限';
      // 清除非管理员的登录状态
      localStorage.removeItem('isAdmin'); // 确保移除 isAdmin 标志
      authStore.logout();
    }
  } catch (e) {
    console.error('Login error:', e);
    error.value = '登录失败，请检查用户名和密码';
  } finally {
    loading.value = false;
  }
};
</script>