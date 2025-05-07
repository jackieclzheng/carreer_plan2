<template>
  <div class="container mx-auto p-4">
    <!-- 错误提示 -->
    <div v-if="error" class="mb-4 p-4 bg-red-100 text-red-700 rounded">
      {{ error }}
    </div>

    <Card class="w-full max-w-4xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <Clock class="mr-2" /> 任务追踪
        </CardTitle>
      </CardHeader>
      <CardContent>
        <!-- 加载状态 -->
        <div v-if="loading" class="flex justify-center items-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
        </div>
        
        <div v-else>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
            <div>
              <Input 
                v-model="newTask.title" 
                placeholder="任务标题" 
                class="mb-2"
              />
              <Input 
                v-model="newTask.description" 
                placeholder="任务描述（可选）" 
                class="mb-2"
              />
              <div class="flex space-x-2">
                <Input 
                  type="date" 
                  v-model="newTask.deadline"
                  class="flex-grow"
                />
                <Select v-model="newTask.status" class="w-1/3">
                  <SelectTrigger>
                    <SelectValue placeholder="状态" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="未开始">未开始</SelectItem>
                    <SelectItem value="进行中">进行中</SelectItem>
                    <SelectItem value="已完成">已完成</SelectItem>
                  </SelectContent>
                </Select>
                <Button @click="addTask">
                  <PlusCircle class="mr-2 h-4 w-4" /> 添加
                </Button>
              </div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm text-gray-600 mb-2">任务统计</h4>
              <div class="grid grid-cols-3 gap-2">
                <div class="bg-blue-100 p-3 rounded text-center">
                  <p class="text-xl font-bold text-blue-600">
                    {{ taskStore.taskStats.total }}
                  </p>
                  <p class="text-xs text-gray-600">总任务数</p>
                </div>
                <div class="bg-green-100 p-3 rounded text-center">
                  <p class="text-xl font-bold text-green-600">
                    {{ taskStore.taskStats.completed }}
                  </p>
                  <p class="text-xs text-gray-600">已完成</p>
                </div>
                <div class="bg-red-100 p-3 rounded text-center">
                  <p class="text-xl font-bold text-red-600">
                    {{ taskStore.taskStats.notStarted }}
                  </p>
                  <p class="text-xs text-gray-600">未开始</p>
                </div>
              </div>
            </div>
          </div>

          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-gray-100">
                <th class="border p-2 text-left">任务标题</th>
                <th class="border p-2 text-left">描述</th>
                <th class="border p-2 text-left">截止日期</th>
                <th class="border p-2 text-left">状态</th>
                <th class="border p-2 text-left">进度</th>
                <th class="border p-2 text-center">操作</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="task in taskStore.tasks" 
                :key="task.id" 
                class="hover:bg-gray-50"
              >
                <td class="border p-2">{{ task.title }}</td>
                <td class="border p-2 text-sm text-gray-600">
                  {{ task.description || '无描述' }}
                </td>
                <td class="border p-2">{{ task.deadline }}</td>
                <td class="border p-2">
                  <span 
                    :class="`
                      px-2 py-1 rounded text-xs
                      ${task.status === '未开始' ? 'bg-red-100 text-red-800' : 
                        task.status === '进行中' ? 'bg-blue-100 text-blue-800' : 
                        'bg-green-100 text-green-800'}
                    `"
                  >
                    {{ task.status }}
                  </span>
                </td>
                <td class="border p-2">
                  <div class="flex items-center">
                    <Input 
                      type="range" 
                      :min="0" 
                      :max="100" 
                      v-model.number="task.progress"
                      @input="updateTaskProgress(task.id, task.progress)"
                      class="mr-2 flex-grow"
                    />
                    <span class="text-sm">{{ task.progress }}%</span>
                  </div>
                </td>
                <td class="border p-2 text-center">
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    @click="removeTask(task.id)"
                  >
                    <Trash2 class="h-4 w-4 text-red-500" />
                  </Button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { 
  Clock, 
  PlusCircle, 
  Trash2 
} from 'lucide-vue-next';
import { useTaskTrackingStore } from '@/stores/task-tracking';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';

const taskStore = useTaskTrackingStore();
const loading = ref(false);
const error = ref('');

// 新任务数据
const newTask = ref({
  title: '',
  description: '',
  deadline: '',
  status: '未开始' as Task['status'],
  progress: 0
});

// 获取任务列表
const fetchTasks = async () => {
  try {
    loading.value = true;
    await taskStore.fetchTasks();
  } catch (e) {
    error.value = '获取任务列表失败';
  } finally {
    loading.value = false;
  }
};

// 添加任务
const addTask = async () => {
  try {
    // 验证输入
    const { title, deadline, status } = newTask.value;
    if (!title || !deadline || !status) {
      error.value = '请填写任务标题、截止日期和状态';
      return;
    }

    loading.value = true;
    await taskStore.addTask({
      ...newTask.value,
      progress: 0
    });

    // 重置表单
    newTask.value = {
      title: '',
      description: '',
      deadline: '',
      status: '未开始',
      progress: 0
    };
  } catch (e) {
    error.value = '添加任务失败';
  } finally {
    loading.value = false;
  }
};

// 更新任务进度
const updateTaskProgress = async (id: number, progress: number) => {
  try {
    loading.value = true;
    await taskStore.updateTask(id, { progress });
  } catch (e) {
    error.value = '更新进度失败';
  } finally {
    loading.value = false;
  }
};

// 删除任务
const removeTask = async (id: number) => {
  try {
    if (!confirm('确定要删除这个任务吗？')) return;
    
    loading.value = true;
    await taskStore.removeTask(id);
  } catch (e) {
    error.value = '删除任务失败';
  } finally {
    loading.value = false;
  }
};

// 组件挂载时获取任务列表
onMounted(() => {
  fetchTasks();
});

// 状态颜色映射
const getStatusColor = (status: Task['status']) => {
  switch(status) {
    case '未开始': return 'bg-red-100 text-red-800';
    case '进行中': return 'bg-blue-100 text-blue-800';
    case '已完成': return 'bg-green-100 text-green-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};
</script>
