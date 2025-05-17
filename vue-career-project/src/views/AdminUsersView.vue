<template>
  <div>
    <h2 class="text-2xl font-semibold mb-6">用户管理</h2>
    
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex justify-between mb-4">
        <Input 
          v-model="searchTerm"
          placeholder="搜索用户..."
          class="w-64"
        />
        <Button @click="openAddUserDialog">
          <UserPlus class="w-4 h-4 mr-2" />
          添加用户
        </Button>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>用户名</TableHead>
            <TableHead>邮箱</TableHead>
            <TableHead>角色</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="user in users" :key="user.id">
            <TableCell>{{ user.username }}</TableCell>
            <TableCell>{{ user.email }}</TableCell>
            <TableCell>{{ user.role }}</TableCell>
            <TableCell>
              <Badge :variant="user.status === '启用' ? 'success' : 'destructive'">
                {{ user.status }}
              </Badge>
            </TableCell>
            <TableCell>
              <Button variant="ghost" size="sm" @click="editUser(user)">
                <Pencil class="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="sm" @click="deleteUser(user)">
                <Trash class="w-4 h-4" />
              </Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { UserPlus, Pencil, Trash } from 'lucide-vue-next';
import { useAdminStore } from '@/stores/admin';

const adminStore = useAdminStore();
const searchTerm = ref('');
const users = ref([]);

onMounted(async () => {
  await adminStore.fetchUsers();
  users.value = adminStore.users;
});

// ...其他方法实现
</script>
