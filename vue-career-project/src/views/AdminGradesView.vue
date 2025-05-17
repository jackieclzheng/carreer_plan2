<template>
  <div>
    <h1 class="text-2xl font-bold mb-4">成绩管理</h1>
    
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="mb-6 flex justify-between items-center">
        <h2 class="text-lg font-semibold">学生成绩列表</h2>
        <button 
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          @click="showAddModal = true"
        >
          添加成绩
        </button>
      </div>
      
      <!-- 过滤和搜索 -->
      <div class="mb-4 flex gap-4">
        <div class="w-64">
          <select 
            v-model="semesterFilter" 
            class="w-full border rounded px-3 py-2"
          >
            <option value="">所有学期</option>
            <option v-for="semester in semesters" :key="semester" :value="semester">
              {{ semester }}
            </option>
          </select>
        </div>
        <div class="flex-1">
          <input 
            type="text"
            v-model="searchQuery"
            placeholder="搜索学生姓名或课程..." 
            class="w-full border rounded px-3 py-2"
          />
        </div>
      </div>
      
      <!-- 成绩表格 -->
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-gray-50">
            <th class="border p-2 text-left">学号</th>
            <th class="border p-2 text-left">学生姓名</th>
            <th class="border p-2 text-left">课程</th>
            <th class="border p-2 text-left">学期</th>
            <th class="border p-2 text-left">成绩</th>
            <th class="border p-2 text-left">学分</th>
            <th class="border p-2 text-left">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading" class="text-center">
            <td colspan="7" class="p-4">加载中...</td>
          </tr>
          <tr v-else-if="filteredGrades.length === 0" class="text-center">
            <td colspan="7" class="p-4">没有找到成绩记录</td>
          </tr>
          <tr v-for="grade in filteredGrades" :key="`${grade.studentId}-${grade.course}`" class="hover:bg-gray-50">
            <td class="border p-2">{{ grade.studentId }}</td>
            <td class="border p-2">{{ grade.studentName }}</td>
            <td class="border p-2">{{ grade.course }}</td>
            <td class="border p-2">{{ grade.semester }}</td>
            <td class="border p-2">
              <span :class="getGradeClass(grade.score)">
                {{ grade.score }}
              </span>
            </td>
            <td class="border p-2">{{ grade.credits }}</td>
            <td class="border p-2">
              <button
                class="text-blue-500 hover:text-blue-700 mr-2"
                @click="editGrade(grade)"
              >
                编辑
              </button>
              <button
                class="text-red-500 hover:text-red-700"
                @click="deleteGrade(grade.studentId, grade.course)"
              >
                删除
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- 添加/编辑成绩模态框 -->
    <div v-if="showAddModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-lg">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? '编辑成绩' : '添加成绩' }}</h2>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">学号</label>
          <input 
            type="text"
            v-model="currentGrade.studentId"
            :disabled="isEditing"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">学生姓名</label>
          <input 
            type="text"
            v-model="currentGrade.studentName"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">课程</label>
          <input 
            type="text"
            v-model="currentGrade.course"
            :disabled="isEditing"
            class="w-full border rounded px-3 py-2"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">学期</label>
          <select 
            v-model="currentGrade.semester"
            class="w-full border rounded px-3 py-2"
          >
            <option v-for="semester in semesters" :key="semester" :value="semester">
              {{ semester }}
            </option>
          </select>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">
            成绩: {{ currentGrade.score }}
          </label>
          <input 
            type="range"
            v-model.number="currentGrade.score"
            min="0"
            max="100"
            class="w-full"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">学分</label>
          <input 
            type="number"
            v-model.number="currentGrade.credits"
            min="0"
            max="10"
            step="0.5"
            class="w-full border rounded px-3 py-2"
          />
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
            @click="saveGrade"
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

interface Grade {
  studentId: string;
  studentName: string;
  course: string;
  semester: string;
  score: number;
  credits: number;
}

// 模拟学期数据
const semesters = ['2023春季', '2023秋季', '2024春季', '2024秋季'];

// 模拟成绩数据
const grades = ref<Grade[]>([
  { studentId: '2020001', studentName: '张三', course: '数据结构', semester: '2023春季', score: 85, credits: 4 },
  { studentId: '2020001', studentName: '张三', course: '操作系统', semester: '2023秋季', score: 78, credits: 3 },
  { studentId: '2020002', studentName: '李四', course: '数据结构', semester: '2023春季', score: 92, credits: 4 },
  { studentId: '2020002', studentName: '李四', course: '计算机网络', semester: '2023秋季', score: 88, credits: 3 },
  { studentId: '2020003', studentName: '王五', course: '数据库系统', semester: '2024春季', score: 95, credits: 4 },
]);

const loading = ref(false);
const semesterFilter = ref('');
const searchQuery = ref('');
const showAddModal = ref(false);
const isEditing = ref(false);
const currentGrade = ref<Grade>({
  studentId: '',
  studentName: '',
  course: '',
  semester: '2024春季',
  score: 80,
  credits: 3
});

// 根据过滤条件筛选成绩
const filteredGrades = computed(() => {
  return grades.value.filter(grade => {
    // 学期筛选
    if (semesterFilter.value && grade.semester !== semesterFilter.value) {
      return false;
    }
    
    // 搜索过滤
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase();
      return (
        grade.studentName.toLowerCase().includes(query) ||
        grade.course.toLowerCase().includes(query) ||
        grade.studentId.toLowerCase().includes(query)
      );
    }
    
    return true;
  });
});

// 获取成绩对应的样式类
const getGradeClass = (score: number) => {
  if (score >= 90) return 'font-bold text-green-600';
  if (score >= 80) return 'font-bold text-blue-600';
  if (score >= 70) return 'font-bold text-yellow-600';
  if (score >= 60) return 'font-bold text-orange-600';
  return 'font-bold text-red-600';
};

// 编辑成绩
const editGrade = (grade: Grade) => {
  isEditing.value = true;
  currentGrade.value = { ...grade };
  showAddModal.value = true;
};

// 保存成绩
const saveGrade = () => {
  if (!currentGrade.value.studentId || !currentGrade.value.studentName || !currentGrade.value.course) {
    alert('请填写学号、学生姓名和课程名称');
    return;
  }
  
  if (isEditing.value) {
    // 更新现有成绩
    const index = grades.value.findIndex(g => 
      g.studentId === currentGrade.value.studentId && g.course === currentGrade.value.course
    );
    if (index !== -1) {
      grades.value[index] = { ...currentGrade.value };
    }
  } else {
    // 添加新成绩
    // 检查是否已存在
    const exists = grades.value.some(g => 
      g.studentId === currentGrade.value.studentId && g.course === currentGrade.value.course
    );
    
    if (exists) {
      alert(`学生 ${currentGrade.value.studentName}(${currentGrade.value.studentId}) 的 ${currentGrade.value.course} 课程成绩已存在`);
      return;
    }
    
    grades.value.push({ ...currentGrade.value });
  }
  
  // 重置表单并关闭模态框
  resetForm();
  showAddModal.value = false;
};

// 删除成绩
const deleteGrade = (studentId: string, course: string) => {
  if (confirm('确定要删除这条成绩记录吗？')) {
    grades.value = grades.value.filter(g => 
      !(g.studentId === studentId && g.course === course)
    );
  }
};

// 重置表单
const resetForm = () => {
  isEditing.value = false;
  currentGrade.value = {
    studentId: '',
    studentName: '',
    course: '',
    semester: '2024春季',
    score: 80,
    credits: 3
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