<template>
  <div class="container mx-auto p-4">
    <Card class="w-full max-w-4xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <BookOpen class="mr-2" /> 成绩管理
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div class="grid grid-cols-3 gap-4 mb-4">
          <div class="bg-blue-50 p-4 rounded-lg">
            <h4 class="text-sm text-gray-600">平均学分绩点(GPA)</h4>
            <p class="text-2xl font-bold text-blue-600">
              {{ academicStore.calculateGPA }}
            </p>
          </div>
          <div class="bg-green-50 p-4 rounded-lg">
            <h4 class="text-sm text-gray-600">总学分</h4>
            <p class="text-2xl font-bold text-green-600">
              {{ academicStore.totalCredits }}
            </p>
          </div>
          <div class="bg-purple-50 p-4 rounded-lg">
            <h4 class="text-sm text-gray-600">课程数量</h4>
            <p class="text-2xl font-bold text-purple-600">
              {{ academicStore.courses.length }}
            </p>
          </div>
        </div>

        <!-- 添加课程表单 -->
        <div class="mb-4 flex space-x-2">
          <Input 
            v-model="newCourse.name" 
            placeholder="课程名称" 
            class="flex-grow"
          />
          <Input 
            v-model="newCourse.semester" 
            placeholder="学期" 
            class="w-1/4"
          />
          <Input 
            v-model.number="newCourse.score" 
            type="number" 
            placeholder="成绩" 
            class="w-1/4"
          />
          <Input 
            v-model.number="newCourse.credits" 
            type="number" 
            placeholder="学分" 
            class="w-1/4"
          />
          <Button @click="addCourse">添加课程</Button>
        </div>

        <!-- 学期分组表格 -->
        <div v-for="(semesterCourses, semester) in academicStore.coursesBySemester" 
             :key="semester" 
             class="mb-6"
        >
          <h3 class="text-lg font-semibold mb-2">{{ semester }}</h3>
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-gray-100">
                <th class="border p-2 text-left">课程名称</th>
                <th class="border p-2 text-right">成绩</th>
                <th class="border p-2 text-right">学分</th>
                <th class="border p-2 text-center">操作</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="course in semesterCourses" 
                :key="course.id" 
                class="hover:bg-gray-50"
              >
                <td class="border p-2">{{ course.name }}</td>
                <td class="border p-2 text-right">
                  <span 
                    :class="`
                      font-bold 
                      ${course.score >= 90 ? 'text-green-600' : 
                        course.score >= 80 ? 'text-blue-600' : 
                        course.score >= 60 ? 'text-yellow-600' : 'text-red-600'}
                    `"
                  >
                    {{ course.score }}
                  </span>
                </td>
                <td class="border p-2 text-right">{{ course.credits }}</td>
                <td class="border p-2 text-center">
                  <AlertDialog>
                    <AlertDialogTrigger as-child>
                      <Button variant="ghost" size="sm">
                        <Edit class="h-4 w-4" />
                      </Button>
                    </AlertDialogTrigger>
                    <AlertDialogContent>
                      <AlertDialogHeader>
                        <AlertDialogTitle>修改成绩</AlertDialogTitle>
                        <AlertDialogDescription>
                          修改 {{ course.name }} 的成绩
                        </AlertDialogDescription>
                      </AlertDialogHeader>
                      <div class="grid gap-4 py-4">
                        <Input 
                          v-model.number="editScore" 
                          type="number" 
                          placeholder="新成绩" 
                        />
                      </div>
                      <AlertDialogFooter>
                        <AlertDialogCancel>取消</AlertDialogCancel>
                        <AlertDialogAction @click="updateScore(course.id)">
                          确认
                        </AlertDialogAction>
                      </AlertDialogFooter>
                    </AlertDialogContent>
                  </AlertDialog>
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
import { ref } from 'vue';
import { BookOpen, Edit } from 'lucide-vue-next';
import { useAcademicPerformanceStore } from '@/stores/academic-performance';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { 
  AlertDialog, 
  AlertDialogAction, 
  AlertDialogCancel, 
  AlertDialogContent, 
  AlertDialogDescription, 
  AlertDialogFooter, 
  AlertDialogHeader, 
  AlertDialogTitle,
  AlertDialogTrigger 
} from '@/components/ui/alert-dialog';

const academicStore = useAcademicPerformanceStore();

// 新课程数据
const newCourse = ref({
  name: '',
  semester: '',
  score: 0,
  credits: 0
});

// 编辑成绩
const editScore = ref(0);

// 添加课程
const addCourse = () => {
  // 验证输入
  if (!newCourse.value.name || !newCourse.value.semester) {
    alert('请填写课程名称和学期');
    return;
  }

  academicStore.addCourse({
    id: 0, // 由 store 自动分配
    name: newCourse.value.name,
    semester: newCourse.value.semester,
    score: newCourse.value.score,
    credits: newCourse.value.credits
  });

  // 重置表单
  newCourse.value = {
    name: '',
    semester: '',
    score: 0,
    credits: 0
  };
};

// 更新成绩
const updateScore = (courseId: number) => {
  if (editScore.value < 0 || editScore.value > 100) {
    alert('成绩必须在0-100之间');
    return;
  }

  academicStore.updateCourseScore(courseId, editScore.value);
};
</script>
