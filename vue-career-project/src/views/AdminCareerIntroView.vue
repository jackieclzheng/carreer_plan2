<template>
  <div>
    <h1 class="text-2xl font-bold mb-4">职业介绍管理</h1>
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="mb-6 flex justify-between items-center">
        <h2 class="text-lg font-semibold">职业介绍列表</h2>
        <button 
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          @click="showAddModal = true"
        >
          添加职业介绍
        </button>
      </div>
      
      <!-- 搜索框 -->
      <div class="mb-4">
        <input 
          type="text"
          v-model="searchQuery"
          placeholder="搜索职业名称..." 
          class="w-full border rounded px-3 py-2"
        />
      </div>
      
      <!-- 职业介绍列表 -->
      <div class="space-y-4">
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"></div>
          <p class="mt-2 text-gray-600">加载中...</p>
        </div>
        
        <div v-else-if="filteredIntros.length === 0" class="text-center py-8">
          <p class="text-gray-600">没有找到职业介绍</p>
        </div>
        
        <div 
          v-for="intro in filteredIntros" 
          :key="intro.id" 
          class="border rounded-lg p-4 hover:shadow-md transition-shadow"
        >
          <div class="flex justify-between items-start mb-3">
            <h3 class="text-lg font-semibold text-blue-700">{{ intro.title }}</h3>
            <div class="flex space-x-2">
              <button
                class="text-blue-500 hover:text-blue-700"
                @click="editIntro(intro)"
              >
                编辑
              </button>
              <button
                class="text-red-500 hover:text-red-700"
                @click="deleteIntro(intro.id)"
              >
                删除
              </button>
            </div>
          </div>
          
          <p class="text-sm text-gray-600 mb-3">{{ intro.summary }}</p>
          
          <div class="mb-3">
            <h4 class="text-sm font-medium text-gray-700 mb-1">工作职责:</h4>
            <ul class="list-disc pl-5 text-sm text-gray-600 space-y-1">
              <li v-for="(responsibility, index) in intro.responsibilities" :key="index">
                {{ responsibility }}
              </li>
            </ul>
          </div>
          
          <div class="mb-3">
            <h4 class="text-sm font-medium text-gray-700 mb-1">所需技能:</h4>
            <ul class="list-disc pl-5 text-sm text-gray-600 space-y-1">
              <li v-for="(skill, index) in intro.skills" :key="index">
                {{ skill }}
              </li>
            </ul>
          </div>
          
          <div class="flex justify-between items-center">
            <span class="text-sm text-gray-500">平均薪资: {{ intro.averageSalary }}</span>
            <span class="text-sm text-gray-500">就业前景: {{ intro.employmentOutlook }}</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 添加/编辑职业介绍模态框 -->
    <div v-if="showAddModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? '编辑职业介绍' : '添加职业介绍' }}</h2>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">职业名称</label>
            <input 
              type="text"
              v-model="currentIntro.title"
              class="w-full border rounded px-3 py-2"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">概述</label>
            <textarea 
              v-model="currentIntro.summary"
              class="w-full border rounded px-3 py-2"
              rows="3"
            ></textarea>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">平均薪资</label>
            <input 
              type="text"
              v-model="currentIntro.averageSalary"
              class="w-full border rounded px-3 py-2"
              placeholder="例如: ¥15,000-¥25,000/月"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">就业前景</label>
            <select 
              v-model="currentIntro.employmentOutlook"
              class="w-full border rounded px-3 py-2"
            >
              <option value="极佳">极佳</option>
              <option value="良好">良好</option>
              <option value="一般">一般</option>
              <option value="不佳">不佳</option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">工作职责 (每行一条)</label>
            <textarea 
              v-model="responsibilitiesInput"
              class="w-full border rounded px-3 py-2"
              rows="5"
              placeholder="负责产品的用户界面设计&#10;与后端开发团队协作&#10;参与产品需求分析和讨论"
            ></textarea>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">所需技能 (每行一条)</label>
            <textarea 
              v-model="skillsInput"
              class="w-full border rounded px-3 py-2"
              rows="5"
              placeholder="熟练掌握HTML/CSS/JavaScript&#10;熟悉React或Vue等前端框架&#10;良好的团队协作能力"
            ></textarea>
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
            @click="saveIntro"
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

interface CareerIntro {
  id: number;
  title: string;
  summary: string;
  responsibilities: string[];
  skills: string[];
  averageSalary: string;
  employmentOutlook: string;
}

// 模拟职业介绍数据
const careerIntros = ref<CareerIntro[]>([
  {
    id: 1,
    title: '前端开发工程师',
    summary: '前端开发工程师负责创建网站和应用程序的用户界面，确保良好的用户体验和视觉吸引力。',
    responsibilities: [
      '使用HTML、CSS和JavaScript开发响应式网站和Web应用',
      '优化网站性能和用户体验',
      '与UI/UX设计师和后端开发人员协作',
      '测试和调试代码',
      '保持对新前端技术和趋势的了解'
    ],
    skills: [
      '熟练掌握HTML5、CSS3和JavaScript',
      '熟悉React、Vue或Angular等前端框架',
      '了解响应式设计和跨浏览器兼容性',
      '基本的后端知识和API集成经验',
      '良好的问题解决能力和团队协作精神'
    ],
    averageSalary: '¥15,000-¥25,000/月',
    employmentOutlook: '极佳'
  },
  {
    id: 2,
    title: '数据分析师',
    summary: '数据分析师收集、处理和分析数据，提供有价值的见解，帮助组织做出明智的业务决策。',
    responsibilities: [
      '收集和整理来自不同来源的数据',
      '使用统计方法和工具分析数据',
      '创建可视化报告和仪表板',
      '识别趋势和模式，提供业务建议',
      '与各部门合作，解决数据相关问题'
    ],
    skills: [
      '熟练使用SQL、Python或R进行数据分析',
      '精通Excel和数据可视化工具（如Tableau、Power BI）',
      '良好的统计学基础',
      '出色的分析思维和解决问题的能力',
      '良好的沟通技巧，能够清晰表达数据见解'
    ],
    averageSalary: '¥12,000-¥22,000/月',
    employmentOutlook: '良好'
  }
]);

const loading = ref(false);
const searchQuery = ref('');
const showAddModal = ref(false);
const isEditing = ref(false);
const responsibilitiesInput = ref('');
const skillsInput = ref('');

const currentIntro = ref<CareerIntro>({
  id: 0,
  title: '',
  summary: '',
  responsibilities: [],
  skills: [],
  averageSalary: '',
  employmentOutlook: '良好'
});

// 根据搜索条件筛选职业介绍
const filteredIntros = computed(() => {
  if (!searchQuery.value) return careerIntros.value;
  
  const query = searchQuery.value.toLowerCase();
  return careerIntros.value.filter(intro => 
    intro.title.toLowerCase().includes(query) ||
    intro.summary.toLowerCase().includes(query)
  );
});

// 编辑职业介绍
const editIntro = (intro: CareerIntro) => {
  isEditing.value = true;
  currentIntro.value = { ...intro };
  responsibilitiesInput.value = intro.responsibilities.join('\n');
  skillsInput.value = intro.skills.join('\n');
  showAddModal.value = true;
};

// 保存职业介绍
const saveIntro = () => {
  if (!currentIntro.value.title || !currentIntro.value.summary) {
    alert('请填写职业名称和概述');
    return;
  }
  
  // 解析输入文本为数组
  currentIntro.value.responsibilities = responsibilitiesInput.value
    .split('\n')
    .map(item => item.trim())
    .filter(item => item.length > 0);
    
  currentIntro.value.skills = skillsInput.value
    .split('\n')
    .map(item => item.trim())
    .filter(item => item.length > 0);
  
  if (isEditing.value) {
    // 更新现有职业介绍
    const index = careerIntros.value.findIndex(intro => intro.id === currentIntro.value.id);
    if (index !== -1) {
      careerIntros.value[index] = { ...currentIntro.value };
    }
  } else {
    // 添加新职业介绍
    const newId = Math.max(0, ...careerIntros.value.map(intro => intro.id)) + 1;
    careerIntros.value.push({
      ...currentIntro.value,
      id: newId
    });
  }
  
  // 重置表单并关闭模态框
  resetForm();
  showAddModal.value = false;
};

// 删除职业介绍
const deleteIntro = (id: number) => {
  if (confirm('确定要删除这个职业介绍吗？')) {
    careerIntros.value = careerIntros.value.filter(intro => intro.id !== id);
  }
};

// 重置表单
const resetForm = () => {
  isEditing.value = false;
  currentIntro.value = {
    id: 0,
    title: '',
    summary: '',
    responsibilities: [],
    skills: [],
    averageSalary: '',
    employmentOutlook: '良好'
  };
  responsibilitiesInput.value = '';
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