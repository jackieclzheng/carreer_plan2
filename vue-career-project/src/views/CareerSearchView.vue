<template>
  <div class="container mx-auto p-4">
    <Card>
      <CardHeader>
        <CardTitle class="flex items-center">
          <Search class="mr-2" /> 职业搜索
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex mb-4">
          <Input 
            placeholder="输入职业名称、描述或技能" 
            v-model="searchTerm"
            class="mr-2"
            :disabled="loading"
          />
          <Button 
            @click="search"
            :disabled="loading"
          >
            <span v-if="loading">搜索中...</span>
            <span v-else>搜索</span>
          </Button>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="text-red-500 mb-4">
          {{ error }}
        </div>

        <!-- 加载中提示 -->
        <div v-if="loading" class="text-center py-4">
          加载中...
        </div>

        <!-- 搜索结果 -->
        <div v-else class="space-y-4">
          <div 
            v-for="career in careerSearchStore.filteredCareers" 
            :key="career.id" 
            class="border rounded-lg p-4 hover:bg-gray-50 transition-colors"
          >
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-lg font-semibold">{{ career.title }}</h3>
              <span class="text-green-600 font-medium">
                平均薪资：{{ career.averageSalary }}
              </span>
            </div>
            <p class="text-gray-600 mb-2">{{ career.description }}</p>
            <div class="flex items-center">
              <span class="mr-2 text-sm text-gray-500">所需技能：</span>
              <span 
                v-for="skill in career.requiredSkills" 
                :key="skill"
                class="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded mr-2"
              >
                {{ skill }}
              </span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { Search } from 'lucide-vue-next';
import { useCareerSearchStore } from '@/stores/career-search';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

const careerSearchStore = useCareerSearchStore();

// 搜索输入
const searchTerm = ref('');

const loading = ref(false);
const error = ref('');

// 搜索方法
const search = async () => {
  try {
    loading.value = true;
    error.value = '';
    await careerSearchStore.searchCareers(searchTerm.value);
  } catch (e) {
    error.value = '搜索失败，请重试';
    console.error(e);
  } finally {
    loading.value = false;
  }
};
</script>
