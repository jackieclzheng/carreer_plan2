<template>
  <div class="container mx-auto p-4">
    <Card class="w-full max-w-5xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <Target class="mr-2" /> 个性化职业规划
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div>
            <div class="mb-4">
              <Label class="block text-sm font-medium text-gray-700 mb-2">
                选择职业方向
              </Label>
              <Select 
                v-model="selectedCareer" 
                @update:modelValue="generatePlan"
              >
                <SelectTrigger>
                  <SelectValue placeholder="请选择职业方向" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem 
                    v-for="career in careerPlanningStore.careerDirections" 
                    :key="career.id" 
                    :value="career.id"
                  >
                    {{ career.title }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <Button 
              @click="generatePlan" 
              class="w-full"
              :disabled="!selectedCareer"
            >
              <Compass class="mr-2 h-4 w-4" /> 生成个性化职业规划
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
        <template v-if="careerPlanningStore.personalizedPlan">
          <div>
            <h3 class="text-xl font-semibold mb-4 flex items-center">
              <CheckCircle class="mr-2 text-green-600" /> 
              {{ careerPlanningStore.personalizedPlan.targetCareer }}职业规划
            </h3>
            
            <div 
              v-for="(semester, semesterIndex) in careerPlanningStore.personalizedPlan.semesters" 
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
                  <template v-if="semester.courses.length > 0">
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
                  <template v-if="semester.certificates.length > 0">
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
import { ref } from 'vue';
import { 
  Target, 
  Compass, 
  BookOpen, 
  Award, 
  Star, 
  CheckCircle 
} from 'lucide-vue-next';
import { useCareerPlanningStore } from '@/stores/career-planning';
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

const careerPlanningStore = useCareerPlanningStore();

// 选择的职业方向
const selectedCareer = ref<number | null>(null);

// 生成个性化职业规划
const generatePlan = () => {
  if (selectedCareer.value) {
    careerPlanningStore.generatePersonalizedPlan(selectedCareer.value);
  }
};

// 更新技能状态
const updateSkillStatus = (semesterIndex: number, skillIndex: number, newStatus: string) => {
  careerPlanningStore.updateSkillStatus(semesterIndex, skillIndex, newStatus);
};
</script>
