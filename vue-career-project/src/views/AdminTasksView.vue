<template>
  <div>
    <h1 class="text-2xl font-bold mb-4">任务管理</h1>
    
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="mb-6 flex justify-between items-center">
        <h2 class="text-lg font-semibold">任务列表</h2>
        <button 
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          @click="showAddTaskModal = true"
        >
          添加任务
        </button>
      </div>
      
      <!-- 任务筛选和搜索 -->
      <div class="mb-4 flex gap-4">
        <div class="w-64">
          <select 
            v-model="statusFilter" 
            class="w-full border rounded px-3 py-2"
          >
            <option value="">所有状态</option>
            <option value="未开始">未开始</option>
            <option value="进行中">进行中</option>
            <option value="已完成">已完成</option>
          </select>
        </div>
        <div class="flex-1">
          <input 
            type="text"
            v-model="searchQuery"
            placeholder="搜索任务..." 
            class="w-full border rounded px-3 py-2"
          />
        </div>
      </div>
      
      <!-- 任务表格 -->
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-gray-50">
            <th class="border p-2 text-left">ID</th>
            <th class="border p-2 text-left">任务标题</th>
            <th class="border p-2 text-left">描述</th>
            <th class="border p-2 text-left">截止日期</th>
            <th class="border p-2 text-left">状态</th>
            <th class="border p-2 text-left">进度</th>
            <th class="border p-2 text-left">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading" class="text-center">
            <td colspan="7" class="p-4">加载中...</td>
          </tr>
          <tr v-else-if="filteredTasks.length === 0" class="text-center">
            <td colspan="7" class="p-4">没有找到任务</td>
          </tr>
          <tr v-for="task in filteredTasks" :key="task.id" class="hover:bg-gray-50">
            <td class="border p-2">{{ task.id }}</td>
            <td class="border p-2">{{ task.title }}</td>
            <td class="border p-2">{{ task.description }}</td>
            <td class="border p-2">{{ task.deadline }}</td>
            <td class="border p-2">
              <span :class="`px-2 py-1 rounded text-xs ${getStatusClass(task.status)}`">
                {{ task.status }}
              </span>
            </td>
            <td class="border p-2">
              <div class="w-full bg-gray-200 rounded-full h-2.5">
                <div 
                  class="bg-blue-600 h-2.5 rounded-full" 
                  :style="`width: ${task.progress}%`"
                ></div>
              </div>
              <div class="text-xs text-right mt-1">{{ task.progress }}%</div>
            </td>
            <td class="border p-2">
              <button
                class="text-blue-500 hover:text-blue-700 mr-2"
                @click="editTask(task)"
              >
                编辑
              </button>
              <button
                class="text-red-500 hover:text-red-700"
                @click="deleteTask(task.id)"
              >
                删除
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- 添加/编辑任务模态框 -->
    <div v-if="showAddTaskModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-lg">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? '编辑任务' : '添加任务' }}</h2>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">任务标题</label>
          <input 
            type="text"
            v-model="currentTask.title"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">任务描述</label>
          <textarea 
            v-model="currentTask.description"
            class="w-full border rounded px-3 py-2"
            rows="3"
          ></textarea>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">截止日期</label>
          <input 
            type="date"
            v-model="currentTask.deadline"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">状态</label>
          <select 
            v-model="currentTask.status"
            class="w-full border rounded px-3 py-2"
          >
            <option value="未开始">未开始</option>
            <option value="进行中">进行中</option>
            <option value="已完成">已完成</option>
          </select>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">
            进度: {{ currentTask.progress }}%
          </label>
          <input 
            type="range"
            v-model.number="currentTask.progress"
            min="0"
            max="100"
            class="w-full"
          />
        </div>
        
        <div class="flex justify-end space-x-2 mt-6">
          <button 
            class="px-4 py-2 border rounded hover:bg-gray-100"
            @click="showAddTaskModal = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            @click="saveTask"
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

interface Task {
  id: number;
  title: string;
  description: string;
  deadline: string;
  status: '未开始' | '进行中' | '已完成';
  progress: number;
}

// 模拟任务数据
const tasks = ref<Task[]>([
  { 
    id: 1, 
    title: '完成技能评估', 
    description: '进行技能水平自我评估', 
    deadline: '2024-05-20', 
    status: '已完成', 
    progress: 100 
  },
  { 
    id: 2, 
    title: '学习React框架', 
    description: '完成React基础课程学习', 
    deadline: '2024-06-15', 
    status: '进行中', 
    progress: 60 
  },
  { 
    id: 3, 
    title: '参加项目实践', 
    description: '参与一个实际项目的开发', 
    deadline: '2024-07-30', 
    status: '未开始', 
    progress: 0 
  }
]);

const loading = ref(false);
const statusFilter = ref('');
const searchQuery = ref('');
const showAddTaskModal = ref(false);
const isEditing = ref(false);
const currentTask = ref<Task>({
  id: 0,
  title: '',
  description: '',
  deadline: '',
  status: '未开始',
  progress: 0
});

// 根据过滤条件筛选任务
const filteredTasks = computed(() => {
  return tasks.value.filter(task => {
    // 状态筛选
    if (statusFilter.value && task.status !== statusFilter.value) {
      return false;
    }
    
    // 搜索过滤
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase();
      return (
        task.title.toLowerCase().includes(query) ||
        task.description.toLowerCase().includes(query)
      );
    }
    
    return true;
  });
});

// 获取状态对应的样式类
const getStatusClass = (status: string) => {
  switch (status) {
    case '未开始': return 'bg-red-100 text-red-800';
    case '进行中': return 'bg-blue-100 text-blue-800';
    case '已完成': return 'bg-green-100 text-green-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};

// 编辑任务
const editTask = (task: Task) => {
  isEditing.value = true;
  currentTask.value = { ...task };
  showAddTaskModal.value = true;
};

// 保存任务
const saveTask = () => {
  if (!currentTask.value.title || !currentTask.value.deadline) {
    alert('请填写任务标题和截止日期');
    return;
  }
  
  if (isEditing.value) {
    // 更新现有任务
    const index = tasks.value.findIndex(t => t.id === currentTask.value.id);
    if (index !== -1) {
      tasks.value[index] = { ...currentTask.value };
    }
  } else {
    // 添加新任务
    const newId = Math.max(0, ...tasks.value.map(t => t.id)) + 1;
    tasks.value.push({
      ...currentTask.value,
      id: newId
    });
  }
  
  // 重置表单并关闭模态框
  resetForm();
  showAddTaskModal.value = false;
};

// 删除任务
const deleteTask = (id: number) => {
  if (confirm('确定要删除这个任务吗？')) {
    tasks.value = tasks.value.filter(t => t.id !== id);
  }
};

// 重置表单
const resetForm = () => {
  isEditing.value = false;
  currentTask.value = {
    id: 0,
    title: '',
    description: '',
    deadline: '',
    status: '未开始',
    progress: 0
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