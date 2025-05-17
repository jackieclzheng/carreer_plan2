<template>
  <div>
    <h2 class="text-2xl font-semibold mb-6">职业方向管理</h2>
    
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex justify-between mb-4">
        <input
          v-model="searchTerm"
          placeholder="搜索职业方向..."
          class="w-64 px-3 py-2 border border-gray-300 rounded-md"
        />
        <button
          @click="openAddDialog"
          class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
        >
          <Plus class="w-4 h-4 mr-2 inline-block" />
          添加职业方向
        </button>
      </div>

      <table class="min-w-full">
        <thead>
          <tr>
            <th class="px-4 py-2 text-left">ID</th>
            <th class="px-4 py-2 text-left">名称</th>
            <th class="px-4 py-2 text-left">描述</th>
            <th class="px-4 py-2 text-left">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="career in careers" :key="career.id" class="border-t">
            <td class="px-4 py-2">{{ career.id }}</td>
            <td class="px-4 py-2">{{ career.title }}</td>
            <td class="px-4 py-2">{{ career.description }}</td>
            <td class="px-4 py-2">
              <button
                @click="editCareer(career)"
                class="text-blue-500 hover:text-blue-700 mr-2"
              >
                <Pencil class="w-4 h-4" />
              </button>
              <button
                @click="deleteCareer(career)"
                class="text-red-500 hover:text-red-700"
              >
                <Trash class="w-4 h-4" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { Plus, Pencil, Trash } from 'lucide-vue-next';
import { useAdminStore } from '@/stores/admin';

const adminStore = useAdminStore();
const searchTerm = ref('');
const careers = ref([]);

onMounted(async () => {
  await fetchCareerDirections();
});

const fetchCareerDirections = async () => {
  try {
    const data = await adminStore.fetchCareerDirections();
    careers.value = data;
  } catch (error) {
    console.error('获取职业方向列表失败:', error);
  }
};

const openAddDialog = () => {
  // TODO: 实现添加职业方向的对话框
};

const editCareer = (career) => {
  // TODO: 实现编辑职业方向的功能
};

const deleteCareer = async (career) => {
  if (confirm('确定要删除这个职业方向吗？')) {
    try {
      await adminStore.deleteCareerDirection(career.id);
      await fetchCareerDirections();
    } catch (error) {
      console.error('删除职业方向失败:', error);
    }
  }
};
</script>