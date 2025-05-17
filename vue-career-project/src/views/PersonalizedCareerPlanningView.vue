<template>
  <!-- <div class="mt-2 text-xs text-gray-500">
    当前选择: ID={{ selectedCareer }}, {{ selectedCareerObject ? selectedCareerObject.title : '未选择' }}
  </div> -->
  <div class="container mx-auto p-4">
    <Card class="w-full max-w-5xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <Target class="mr-2" /> 个性化职业规划
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div v-if="error" class="mb-4 p-4 bg-red-100 text-red-700 rounded">
          {{ error }}
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div>
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                选择职业方向
              </Label>
              
              <!-- 保留原始Select组件 -->
              <!-- <Select 
                v-model="selectedCareer" 
                @update:modelValue="onCareerChange"
              >
                <SelectTrigger>
                  <SelectValue placeholder="请选择职业方向" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem 
                    v-for="career in careerDirections" 
                    :key="career.id" 
                    :value="career.id"
                  >
                    {{ career.title }}
                  </SelectItem>
                </SelectContent>
              </Select>-->
            </div> 

            <!-- <Select 
                v-model="selectedCareer" 
                @update:modelValue="onCareerChange"
              >
                <SelectTrigger>
                  <SelectValue placeholder="请选择职业方向" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem 
                    v-for="career in careerDirections" 
                    :key="career.id" 
                    :value="career.id"
                  >
                    {{ career.title }} (ID: {{ career.id }})
                  </SelectItem>
                </SelectContent>
              </Select> -->

              <select 
                v-model="selectedCareer" 
                @change="onCareerChange"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            >
                <option value="" disabled>请选择职业方向</option>
                <option 
                    v-for="career in careerDirections" 
                    :key="career.id" 
                    :value="career.id"
                >
                    {{ career.title }} (ID: {{ career.id }})
                </option>
            </select>
            
            <!-- 生成按钮 - 发起后台请求 -->
            <Button 
              class="w-full"
              @click="generatePlanWithBackendRequest"
            >
              <div v-if="loading" class="mr-2 h-4 w-4 animate-spin rounded-full border-b-2 border-white"></div>
              <Compass v-else class="mr-2 h-4 w-4" /> 
              {{ loading ? '正在生成...' : '生成个性化职业规划' }}
            </Button>
          </div>
          <div class="bg-gray-50 p-4 rounded-lg">
            <h4 class="text-sm text-gray-600 mb-2">职业规划指导</h4>
            <div class="space-y-2">
              <div class="flex items-center bg-white p-2 rounded">
                <BookOpen class="mr-2 text-blue-500" />
                <span class="text-sm">选择适合自己的职业方向</span>
              </div>
              <div class="flex items-center bg-white p-2 rounded">
                <Award class="mr-2 text-green-500" />
                <span class="text-sm">制定清晰的学习目标</span>
              </div>
              <div class="flex items-center bg-white p-2 rounded">
                <Star class="mr-2 text-yellow-500" />
                <span class="text-sm">持续跟踪和调整规划</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 职业规划详情 -->
        <template v-if="personalizedPlan">
          <div>
            <h3 class="text-xl font-semibold mb-4 flex items-center">
              <CheckCircle class="mr-2 text-green-600" /> 
              {{ personalizedPlan.targetCareer }}职业规划
            </h3>
            
            <div 
              v-for="(semester, semesterIndex) in personalizedPlan.semesters" 
              :key="semester.semester" 
              class="mb-6 p-4 bg-gray-50 rounded-lg"
            >
              <h4 class="text-lg font-medium mb-3">
                {{ semester.semester }}学期规划
              </h4>
              
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <!-- 技能模块 -->
                <div>
                  <h5 class="font-semibold mb-2">技能培养</h5>
                  <div 
                    v-for="(skill, skillIndex) in semester.skills" 
                    :key="skill.name" 
                    class="bg-white p-3 rounded mb-2 shadow-sm"
                  >
                    <div class="flex justify-between items-center mb-2">
                      <span class="font-medium">{{ skill.name }}</span>
                      <span 
                        :class="`
                          text-xs px-2 py-1 rounded 
                          ${skill.status === '进行中' ? 'bg-blue-100 text-blue-800' : 
                            skill.status === '已完成' ? 'bg-green-100 text-green-800' : 
                            'bg-red-100 text-red-800'}
                        `"
                      >
                        {{ skill.status }}
                      </span>
                    </div>
                    <div class="text-sm text-gray-600 mb-2">
                      目标：{{ skill.semesterGoal }}
                    </div>
                    <Select 
                      :value="skill.status"
                      @update:modelValue="(newStatus) => updateSkillStatus(semesterIndex, skillIndex, newStatus)"
                    >
                      <SelectTrigger class="w-full">
                        <SelectValue placeholder="更新状态" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="未开始">未开始</SelectItem>
                        <SelectItem value="进行中">进行中</SelectItem>
                        <SelectItem value="已完成">已完成</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <!-- 课程模块 -->
                <div>
                  <h5 class="font-semibold mb-2">推荐课程</h5>
                  <template v-if="semester.courses && semester.courses.length > 0">
                    <div 
                      v-for="course in semester.courses" 
                      :key="course.name" 
                      class="bg-white p-3 rounded mb-2 shadow-sm"
                    >
                      <div class="flex justify-between items-center">
                        <span class="font-medium">{{ course.name }}</span>
                        <span class="text-sm text-gray-600">
                          {{ course.semester }}
                        </span>
                      </div>
                    </div>
                  </template>
                  <div v-else class="text-center text-gray-500 py-4">
                    本学期暂无推荐课程
                  </div>
                </div>

                <!-- 证书模块 -->
                <div>
                  <h5 class="font-semibold mb-2">推荐证书</h5>
                  <template v-if="semester.certificates && semester.certificates.length > 0">
                    <div 
                      v-for="cert in semester.certificates" 
                      :key="cert.name" 
                      class="bg-white p-3 rounded mb-2 shadow-sm"
                    >
                      <div class="flex justify-between items-center">
                        <span class="font-medium">{{ cert.name }}</span>
                        <span class="text-sm text-gray-600">
                          {{ cert.semester }}
                        </span>
                      </div>
                    </div>
                  </template>
                  <div v-else class="text-center text-gray-500 py-4">
                    本学期暂无推荐证书
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { 
  Target, 
  Compass, 
  BookOpen, 
  Award, 
  Star, 
  CheckCircle
} from 'lucide-vue-next';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import axios from 'axios';

// 预设职业方向列表
const careerDirections = ref([
  { id: 1, title: '前端开发工程师', description: '专注于Web前端开发技术' },
  { id: 2, title: '后端开发工程师', description: 'Java企业级应用开发' },
  { id: 3, title: 'Python开发工程师', description: 'Python应用开发和数据分析' },
  { id: 4, title: '全栈开发工程师', description: '前后端全栈开发技术' },
  { id: 5, title: '数据工程师', description: '大数据处理和分析' },
  { id: 6, title: 'DevOps工程师', description: '开发运维一体化' }
]);

// 状态管理
const selectedCareer = ref<number | null>(null);
const loading = ref(false);
const error = ref('');
const clickCount = ref(0);
const lastClickTime = ref('');
const personalizedPlan = ref(null);

// 计算属性 - 当前选择的职业对象
const selectedCareerObject = computed(() => {
  if (!selectedCareer.value) return null;
  return careerDirections.value.find(career => career.id === selectedCareer.value) || null;
});

// 页面加载时自动选择职业方向
onMounted(() => {
  console.log('[页面加载] 组件已挂载');
  // 默认选择第一个职业方向
  if (careerDirections.value.length > 0) {
    console.log('[页面加载] 自动选择第一个职业方向');
    selectedCareer.value = careerDirections.value[0].id;
    console.log('[页面加载] 选择的职业ID:', selectedCareer.value);
  }
  
  // 获取职业方向列表
  fetchCareerDirections();
});

// 获取职业方向列表
const fetchCareerDirections = async () => {
  try {
    console.log('[API请求] 获取职业方向列表');
    const response = await axios.get('http://localhost:8080/api/career-planning/directions');
    if (response.data && Array.isArray(response.data)) {
      careerDirections.value = response.data;
      console.log('[API请求] 成功获取职业方向列表:', response.data);
      
      // 如果已有选择的职业被移除，重置选择
      if (selectedCareer.value && !careerDirections.value.some(c => c.id === selectedCareer.value)) {
        selectedCareer.value = careerDirections.value[0]?.id || null;
      }
    }
  } catch (err) {
    console.error('[API请求] 获取职业方向列表失败，使用默认数据:', err);
    // 使用默认数据，已在初始化时设置
  }
};

// 处理职业方向选择变化
// const onCareerChange = (value: number) => {
//   console.log('[UI事件] 职业选择变更为:', value);
//   // 确保value是数字类型
//   selectedCareer.value = typeof value === 'string' ? parseInt(value, 10) : value;
//   console.log('[UI事件] 转换后的职业ID:', selectedCareer.value);
//   error.value = '';
// };

// const onCareerChange = (value) => {
//   console.log('[UI事件] 职业选择变更为:', value, '类型:', typeof value);
  
//   // 确保是数字类型
//   const numValue = typeof value === 'string' ? parseInt(value, 10) : value;
//   console.log('[UI事件] 转换后值:', numValue, '类型:', typeof numValue);
  
//   // 更新状态
//   selectedCareer.value = numValue;
//   console.log('[UI事件] 状态已更新:', selectedCareer.value);
//   error.value = '';
// };


// // 修改前的方法
// const onCareerChange = (value) => {
//   console.log('[UI事件] 职业选择变更为:', value, '类型:', typeof value);
  
//   // 确保是数字类型
//   const numValue = typeof value === 'string' ? parseInt(value, 10) : value;
//   console.log('[UI事件] 转换后值:', numValue, '类型:', typeof numValue);
  
//   // 更新状态
//   selectedCareer.value = numValue;
//   console.log('[UI事件] 状态已更新:', selectedCareer.value);
//   error.value = '';
// };

// 修改后的方法
const onCareerChange = (event) => {
  // 对于select元素，直接从event.target.value获取值
  const value = event.target ? event.target.value : event;
  console.log('[UI事件] 职业选择变更为:', value, '类型:', typeof value);
  
  // 确保是数字类型
  const numValue = typeof value === 'string' ? parseInt(value, 10) : value;
  console.log('[UI事件] 转换后值:', numValue, '类型:', typeof numValue);
  
  // 更新状态
  selectedCareer.value = numValue;
  console.log('[UI事件] 状态已更新:', selectedCareer.value);
  error.value = '';
};

// 生成按钮点击 - 发起后台请求
const generatePlanWithBackendRequest = async () => {
  console.log('[生成按钮] 按钮点击事件触发');
  clickCount.value++;
  lastClickTime.value = new Date().toLocaleTimeString();
  
  if (!selectedCareer.value) {
    console.warn('[生成按钮] 未选择职业方向');
    error.value = '请先选择职业方向';
    return;
  }
  
  console.log('[生成按钮] 开始生成规划，选择的职业ID:', selectedCareer.value);
  loading.value = true;
  error.value = '';
  
  try {
    // 尝试发起后台请求
    console.log('[API请求] 发送生成规划请求');
    
    // 尝试多个可能的API端点
    let response;
    try {
      // 方法1：使用career-planning/plan端点
      response = await axios.post('http://localhost:8080/api/career-planning/plan', {
        selectedCareer: selectedCareer.value
      });
      console.log('[API请求] 使用plan端点成功:', response.data);
    } catch (primaryError) {
      console.log('[API请求] plan端点失败，尝试备用端点:', primaryError);
      
      try {
        // 方法2：使用career-planning/generate端点
        response = await axios.post('http://localhost:8080/api/career-planning/generate', {
          careerId: selectedCareer.value
        });
        console.log('[API请求] 使用generate端点成功:', response.data);
      } catch (secondaryError) {
        console.log('[API请求] generate端点失败，尝试public端点:', secondaryError);
        
        // 方法3：使用public/career-planning/plan端点
        response = await axios.post('http://localhost:8080/api/public/career-planning/plan', {
          selectedCareer: selectedCareer.value
        });
        console.log('[API请求] 使用public端点成功:', response.data);
      }
    }
    
    // 处理响应数据
    if (response && response.data) {
      personalizedPlan.value = response.data;
      console.log('[生成按钮] 请求成功，获取到规划数据:', response.data);
    } else {
      throw new Error('获取到的数据无效');
    }
  } catch (err) {
    console.error('[生成按钮] 所有API请求失败，使用本地模拟数据:', err);
    // 所有API请求失败，回退到本地模拟数据
    const mockData = generateMockPlan(selectedCareer.value);
    personalizedPlan.value = mockData;
    console.log('[生成按钮] 使用模拟数据:', mockData);
  } finally {
    loading.value = false;
    console.log('[生成按钮] 请求处理完成');
  }
};

// 之前的生成按钮功能（只使用本地数据）
const onGenerateClick = () => {
  console.log('[生成按钮] 按钮点击事件触发');
  clickCount.value++;
  lastClickTime.value = new Date().toLocaleTimeString();
  
  if (!selectedCareer.value) {
    console.warn('[生成按钮] 未选择职业方向');
    error.value = '请先选择职业方向';
    return;
  }
  
  console.log('[生成按钮] 开始生成规划，选择的职业ID:', selectedCareer.value);
  loading.value = true;
  error.value = '';
  
  // 模拟异步操作
  setTimeout(() => {
    try {
      // 直接生成模拟数据
      console.log('[生成按钮] 生成模拟数据');
      const mockData = generateMockPlan(selectedCareer.value!);
      personalizedPlan.value = mockData;
      console.log('[生成按钮] 生成成功:', mockData);
    } catch (err) {
      console.error('[生成按钮] 生成失败:', err);
      error.value = '生成规划失败';
    } finally {
      loading.value = false;
    }
  }, 1000);
};

// 更新技能状态
const updateSkillStatus = async (semesterIndex: number, skillIndex: number, newStatus: string) => {
  console.log(`[updateSkillStatus] 更新技能: 学期${semesterIndex}, 技能${skillIndex}, 新状态:${newStatus}`);
  
  // 本地更新
  if (personalizedPlan.value?.semesters) {
    const semester = personalizedPlan.value.semesters[semesterIndex];
    if (semester?.skills) {
      semester.skills[skillIndex].status = newStatus;
      console.log('[updateSkillStatus] 本地更新成功');
      
      // 尝试发送更新到后端
      try {
        console.log('[API请求] 发送技能状态更新');
        await axios.patch('http://localhost:8080/api/career-planning/plan/skills', {
          semesterIndex,
          skillIndex,
          newStatus
        });
        console.log('[API请求] 技能状态更新成功');
      } catch (err) {
        console.error('[API请求] 技能状态更新失败:', err);
        // 失败时不影响用户体验，仍保留本地更新
      }
    }
  }
};

// 生成模拟数据
const generateMockPlan = (careerId: number) => {
  console.log('[generateMockPlan] 生成模拟数据，职业ID:', careerId);
  
  const career = careerDirections.value.find(c => c.id === careerId);
  const careerTitle = career ? career.title : '软件工程师';
  
  // 技能名称和目标
  let skill1, skill2, skill3;
  let course1, course2;
  let cert;
  
  if (careerId === 1) { // 前端
    skill1 = { name: 'HTML/CSS', semesterGoal: '掌握HTML5和CSS3基础', status: '进行中' };
    skill2 = { name: 'JavaScript', semesterGoal: '掌握JavaScript和DOM编程', status: '未开始' };
    skill3 = { name: '前端框架', semesterGoal: '学习React/Vue等主流框架', status: '未开始' };
    course1 = { name: 'Web前端开发基础', semester: '大二上' };
    course2 = { name: 'JavaScript编程', semester: '大二下' };
    cert = { name: '前端开发工程师认证', semester: '大三上' };
  } else if (careerId === 2) { // Java后端
    skill1 = { name: 'Java基础', semesterGoal: '掌握Java核心语法', status: '进行中' };
    skill2 = { name: 'Spring框架', semesterGoal: '学习Spring Boot开发', status: '未开始' };
    skill3 = { name: '数据库设计', semesterGoal: '掌握SQL和数据库优化', status: '未开始' };
    course1 = { name: 'Java程序设计', semester: '大二上' };
    course2 = { name: 'Spring框架入门', semester: '大二下' };
    cert = { name: 'Java工程师认证', semester: '大三上' };
  } else { // 其他职业
    skill1 = { name: '编程基础', semesterGoal: '掌握编程基本概念', status: '进行中' };
    skill2 = { name: '算法与数据结构', semesterGoal: '学习常用算法', status: '未开始' };
    skill3 = { name: '专业领域技能', semesterGoal: '掌握专业技术', status: '未开始' };
    course1 = { name: '程序设计基础', semester: '大二上' };
    course2 = { name: '数据结构与算法', semester: '大二下' };
    cert = { name: '软件开发工程师认证', semester: '大三上' };
  }
  
  return {
    targetCareer: careerTitle,
    semesters: [
      {
        semester: '大二上',
        skills: [skill1],
        courses: [course1],
        certificates: []
      },
      {
        semester: '大二下',
        skills: [skill2],
        courses: [course2],
        certificates: []
      },
      {
        semester: '大三上',
        skills: [skill3],
        courses: [],
        certificates: [cert]
      }
    ]
  };
};
</script>