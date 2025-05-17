<template>
  <div>
    <h1 class="text-2xl font-bold mb-4">公告管理</h1>
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="mb-6 flex justify-between items-center">
        <h2 class="text-lg font-semibold">公告列表</h2>
        <button 
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          @click="showAddModal = true"
        >
          发布公告
        </button>
      </div>
      
      <!-- 过滤和搜索 -->
      <div class="mb-4 flex gap-4">
        <div class="w-64">
          <select 
            v-model="statusFilter" 
            class="w-full border rounded px-3 py-2"
          >
            <option value="">所有状态</option>
            <option value="已发布">已发布</option>
            <option value="草稿">草稿</option>
            <option value="已过期">已过期</option>
          </select>
        </div>
        <div class="flex-1">
          <input 
            type="text"
            v-model="searchQuery"
            placeholder="搜索公告标题..." 
            class="w-full border rounded px-3 py-2"
          />
        </div>
      </div>
      
      <!-- 公告表格 -->
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-gray-50">
            <th class="border p-2 text-left">ID</th>
            <th class="border p-2 text-left">标题</th>
            <th class="border p-2 text-left">内容摘要</th>
            <th class="border p-2 text-left">发布日期</th>
            <th class="border p-2 text-left">状态</th>
            <th class="border p-2 text-left">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading" class="text-center">
            <td colspan="6" class="p-4">加载中...</td>
          </tr>
          <tr v-else-if="filteredAnnouncements.length === 0" class="text-center">
            <td colspan="6" class="p-4">没有找到公告</td>
          </tr>
          <tr v-for="announcement in filteredAnnouncements" :key="announcement.id" class="hover:bg-gray-50">
            <td class="border p-2">{{ announcement.id }}</td>
            <td class="border p-2">{{ announcement.title }}</td>
            <td class="border p-2">{{ truncate(announcement.content, 50) }}</td>
            <td class="border p-2">{{ announcement.publishDate }}</td>
            <td class="border p-2">
              <span :class="`px-2 py-1 rounded text-xs ${getStatusClass(announcement.status)}`">
                {{ announcement.status }}
              </span>
            </td>
            <td class="border p-2">
              <button
                class="text-blue-500 hover:text-blue-700 mr-2"
                @click="editAnnouncement(announcement)"
              >
                编辑
              </button>
              <button
                class="text-red-500 hover:text-red-700"
                @click="deleteAnnouncement(announcement.id)"
              >
                删除
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- 添加/编辑公告模态框 -->
    <div v-if="showAddModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-2xl">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? '编辑公告' : '发布公告' }}</h2>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">公告标题</label>
          <input 
            type="text"
            v-model="currentAnnouncement.title"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">公告内容</label>
          <textarea 
            v-model="currentAnnouncement.content"
            class="w-full border rounded px-3 py-2"
            rows="8"
          ></textarea>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">发布日期</label>
            <input 
              type="date"
              v-model="currentAnnouncement.publishDate"
              class="w-full border rounded px-3 py-2"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">状态</label>
            <select 
              v-model="currentAnnouncement.status"
              class="w-full border rounded px-3 py-2"
            >
              <option value="已发布">已发布</option>
              <option value="草稿">草稿</option>
              <option value="已过期">已过期</option>
            </select>
          </div>
        </div>
        
        <div class="flex justify-end space-x-2 mt-6">
          <button 
            class="px-4 py-2 border rounded hover:bg-gray-100"
            @click="showAddModal = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            @click="saveAnnouncement"
          >
            保存
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

interface Announcement {
  id: number;
  title: string;
  content: string;
  publishDate: string;
  status: '已发布' | '草稿' | '已过期';
}

// 模拟公告数据
const announcements = ref<Announcement[]>([
  {
    id: 1,
    title: '系统升级通知',
    content: '亲爱的用户，我们将于2024年5月20日进行系统升级，升级期间系统将不可用，请提前做好准备。升级完成后，您将享受到更流畅的使用体验和更多新功能。',
    publishDate: '2024-05-15',
    status: '已发布'
  },
  {
    id: 2,
    title: '新功能发布：职业测评',
    content: '我们很高兴地宣布，职业规划平台新增了职业测评功能。通过科学的测评方法，帮助您更好地了解自己的职业倾向和优势，为职业规划提供更精准的指导。',
    publishDate: '2024-04-10',
    status: '已发布'
  },
  {
    id: 3,
    title: '暑期实习机会',
    content: '暑期实习招募开始了！我们整理了多家知名企业的实习岗位信息，涵盖技术、产品、设计等多个方向，欢迎有意向的同学前往"实习招聘"板块查看详情。',
    publishDate: '2024-06-01',
    status: '草稿'
  }
]);

const loading = ref(false);
const statusFilter = ref('');
const searchQuery = ref('');
const showAddModal = ref(false);
const isEditing = ref(false);

const currentAnnouncement = ref<Announcement>({
  id: 0,
  title: '',
  content: '',
  publishDate: new Date().toISOString().split('T')[0],
  status: '草稿'
});

// 根据过滤条件筛选公告
const filteredAnnouncements = computed(() => {
  return announcements.value.filter(announcement => {
    // 状态筛选
    if (statusFilter.value && announcement.status !== statusFilter.value) {
      return false;
    }
    
    // 搜索过滤
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase();
      return (
        announcement.title.toLowerCase().includes(query) ||
        announcement.content.toLowerCase().includes(query)
      );
    }
    
    return true;
  });
});

// 获取状态对应的样式类
const getStatusClass = (status: string) => {
  switch (status) {
    case '已发布': return 'bg-green-100 text-green-800';
    case '草稿': return 'bg-blue-100 text-blue-800';
    case '已过期': return 'bg-gray-100 text-gray-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};

// 截断文本
const truncate = (text: string, length: number) => {
  if (text.length <= length) return text;
  return text.substring(0, length) + '...';
};

// 编辑公告
const editAnnouncement = (announcement: Announcement) => {
  isEditing.value = true;
  currentAnnouncement.value = { ...announcement };
  showAddModal.value = true;
};

// 保存公告
const saveAnnouncement = () => {
  if (!currentAnnouncement.value.title || !currentAnnouncement.value.content) {
    alert('请填写公告标题和内容');
    return;
  }
  
  if (isEditing.value) {
    // 更新现有公告
    const index = announcements.value.findIndex(a => a.id === currentAnnouncement.value.id);
    if (index !== -1) {
      announcements.value[index] = { ...currentAnnouncement.value };
    }
  } else {
    // 添加新公告
    const newId = Math.max(0, ...announcements.value.map(a => a.id)) + 1;
    announcements.value.push({
      ...currentAnnouncement.value,
      id: newId
    });
  }
  
  // 重置表单并关闭模态框
  resetForm();
  showAddModal.value = false;
};

// 删除公告
const deleteAnnouncement = (id: number) => {
  if (confirm('确定要删除这条公告吗？')) {
    announcements.value = announcements.value.filter(a => a.id !== id);
  }
};

// 重置表单
const resetForm = () => {
  isEditing.value = false;
  currentAnnouncement.value = {
    id: 0,
    title: '',
    content: '',
    publishDate: new Date().toISOString().split('T')[0],
    status: '草稿'
  };
};

// 组件挂载时加载数据
onMounted(() => {
  // 在实际应用中这里会调用API获取数据
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
  }, 500);
});
</script>