<template>
  <header class="bg-white shadow-sm p-4 flex justify-between items-center">
    <div>
      <!-- 可以添加面包屑或其他导航元素 -->
    </div>
    <div class="flex items-center space-x-4">
      <span>{{ user?.username }}</span>
      <Button @click="logout" variant="destructive">
        退出登录
      </Button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Button } from '@/components/ui/button'

const authStore = useAuthStore()
const router = useRouter()

const user = computed(() => authStore.user)

const logout = () => {
  authStore.logout()
  router.push('/login')
}
</script>
