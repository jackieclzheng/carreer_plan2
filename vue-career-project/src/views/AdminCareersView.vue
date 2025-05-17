<template>
  <div>
    <h1 class="text-2xl font-bold mb-4">职业管理</h1>
    
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="mb-6 flex justify-between items-center">
        <h2 class="text-lg font-semibold">职业列表</h2>
        <button 
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          @click="showAddModal = true"
        >
          添加职业
        </button>
      </div>
      
      <!-- 过滤和搜索 -->
      <div class="mb-4 flex gap-4">
        <div class="w-64">
          <select 
            v-model="categoryFilter" 
            class="w-full border rounded px-3 py-2"
          >
            <option value="">所有类别</option>
            <option v-for="category in categories" :key="category" :value="category">
              {{ category }}
            </option>
          </select>
        </div>
        <div class="flex-1">
          <input 
            type="text"
            v-model="searchQuery"
            placeholder="搜索职业名称或描述..." 
            class="w-full border rounded px-3 py-2"
          />
        </div>
      </div>
      
      <!-- 职业列表 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-if="loading" class="col-span-3 text-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"></div>
          <p class="mt-2 text-gray-600">加载中...</p>
        </div>
        
        <div v-else-if="filteredCareers.length === 0" class="col-span-3 text-center py-8">
          <p class="text-gray-600">没有找到职业信息</p>
        </div>
        
        <div 
          v-for="career in filteredCareers" 
          :key="career.id" 
          class="bg-gray-50 p-4 rounded-lg border hover:shadow-md transition-shadow"
        >
          <div class="flex justify-between items-start mb-2">
            <h3 class="text-lg font-semibold text-blue-700">{{ career.title }}</h3>
            <span class="text-xs px-2 py-1 bg-blue-100 text-blue-800 rounded">{{ career.category }}</span>
          </div>
          
          <p class="text-sm text-gray-600 mb-3">{{ career.description }}</p>
          
          <div class="mb-3">
            <h4 class="text-sm font-medium text-gray-700 mb-1">所需技能:</h4>
            <div class="flex flex-wrap gap-1">
              <span 
                v-for="skill in career.skills" 
                :key="skill"
                class="text-xs px-2 py-1 bg-gray-200 rounded-full"
              >
                {{ skill }}
              </span>
            </div>
          </div>
          
          <div class="flex justify-between items-center">
            <span class="text-green-600 font-medium">{{ career.salary }}</span>
            <div class="space-x-2">
              <button
                class="text-blue-500 hover:text-blue-700"
                @click="editCareer(career)"
              >
                编辑
              </button>
              <button
                class="text-red-500 hover:text-red-700"
                @click="deleteCareer(career.id)"
              >
                删除
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 添加/编辑职业模态框 -->
    <div v-if="showAddModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-2xl">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? '编辑职业' : '添加职业' }}</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">职业名称</label>
            <input 
              type="text"
              v-model="currentCareer.title"
              class="w-full border rounded px-3 py-2"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">职业类别</label>
            <select 
              v-model="currentCareer.category"
              class="w-full border rounded px-3 py-2"
            >
              <option v-for="category in categories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">薪资范围</label>
            <input 
              type="text"
              v-model="currentCareer.salary"
              class="w-full border rounded px-3 py-2"
              placeholder="例如: 10k-15k/月"
            />
          </div>
          
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">职业描述</label>
            <textarea 
              v-model="currentCareer.description"
              class="w-full border rounded px-3 py-2"
              rows="4"
            ></textarea>
          </div>
          
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">所需技能 (用逗号分隔)</label>
            <input 
              type="text"
              v-model="skillsInput"
              class="w-full border rounded px-3 py-2"
              placeholder="例如: Java, Spring Boot, MySQL"
            />
            <div class="mt-2 flex flex-wrap gap-1">
              <span 
                v-for="skill in parsedSkills" 
                :key="skill"
                class="text-xs px-2 py-1 bg-gray-200 rounded-full"
              >
                {{ skill }}
              </span>
            </div>
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
            @click="saveCareer"
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

interface Career {
  id: number;
  title: string;
  category: string;
  description: string;
  skills: string[];
  salary: string;
}

// 职业类别
const categories = [
  '技术/IT',
  '金融/会计',
  '市场/营销',
  '设计/创意',
  '管理/行政',
  '教育/培训',
  '医疗/健康',
  '法律/咨询',
  '销售/客服',
  '其他'
];

// 模拟职业数据
const careers = ref<Career[]>([
  {
    id: 1,
    title: '前端开发工程师',
    category: '技术/IT',
    description: '负责网站和web应用程序的用户界面开发，与设计师和后端开发人员合作，创建高质量的用户体验。',
    skills: ['JavaScript', 'HTML', 'CSS', 'React', 'Vue'],
    salary: '15k-25k/月'
  },
  {
    id: 2,
    title: '后端开发工程师',
    category: '技术/IT',
    description: '负责服务器、应用程序和数据库的开发和维护，确保系统的高性能、响应速度和安全性。',
    skills: ['Java', 'Spring Boot', 'MySQL', 'Redis', 'Docker'],
    salary: '20k-35k/月'
  },
  {
    id: 3,
    title: '产品经理',
    category: '管理/行政',
    description: '负责定义产品愿景、确定产品功能和需求，协调开发团队，确保产品按时高质量交付。',
    skills: ['需求分析', '市场调研', '项目管理', '沟通协调', 'User Story'],
    salary: '25k-40k/月'
  },
  {
    id: 4,
    title: 'UI/UX设计师',
    category: '设计/创意',
    description: '负责应用程序或网站的视觉设计和用户体验，创建直观、美观且功能强大的用户界面。',
    skills: ['Figma', 'Sketch', 'Adobe XD', '原型设计', '用户研究'],
    salary: '15k-30k/月'
  }
]);

const loading = ref(false);
const categoryFilter = ref('');
const searchQuery = ref('');
const showAddModal = ref(false);
const isEditing = ref(false);
const skillsInput = ref('');

const currentCareer = ref<Career>({
  id: 0,
  title: '',
  category: '技术/IT',
  description: '',
  skills: [],
  salary: ''
});

// 解析技能输入
const parsedSkills = computed(() => {
  return skillsInput.value
    .split(',')
    .map(skill => skill.trim())
    .filter(skill => skill.length > 0);
});

// 根据过滤条件筛选职业
const filteredCareers = computed(() => {
  return careers.value.filter(career => {
    // 类别筛选
    if (categoryFilter.value && career.category !== categoryFilter.value) {
      return false;
    }
    
    // 搜索过滤
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase();
      return (
        career.title.toLowerCase().includes(query) ||
        career.description.toLowerCase().includes(query) ||
        career.skills.some(skill => skill.toLowerCase().includes(query))
      );
    }
    
    return true;
  });
});

// 编辑职业
const editCareer = (career: Career) => {
  isEditing.value = true;
  currentCareer.value = { ...career };
  skillsInput.value = career.skills.join(', ');
  showAddModal.value = true;
};

// 保存职业
const saveCareer = () => {
  if (!currentCareer.value.title || !currentCareer.value.description) {
    alert('请填写职业名称和描述');
    return;
  }
  
  // 使用解析的技能
  currentCareer.value.skills = parsedSkills.value;
  
  if (isEditing.value) {
    // 更新现有职业
    const index = careers.value.findIndex(c => c.id === currentCareer.value.id);
    if (index !== -1) {
      careers.value[index] = { ...currentCareer.value };
    }
  } else {
    // 添加新职业
    const newId = Math.max(0, ...careers.value.map(c => c.id)) + 1;
    careers.value.push({
      ...currentCareer.value,
      id: newId
    });
  }
  
  // 重置表单并关闭模态框
  resetForm();
  showAddModal.value = false;
};

// 删除职业
const deleteCareer = (id: number) => {
  if (confirm('确定要删除这个职业吗？')) {
    careers.value = careers.value.filter(c => c.id !== id);
  }
};

// 重置表单
const resetForm = () => {
  isEditing.value = false;
  currentCareer.value = {
    id: 0,
    title: '',
    category: '技术/IT',
    description: '',
    skills: [],
    salary: ''
  };
  skillsInput.value = '';
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