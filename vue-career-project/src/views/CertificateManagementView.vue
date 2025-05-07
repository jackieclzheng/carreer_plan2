<template>
  <div class="container mx-auto p-4">
    <Card class="w-full max-w-4xl mx-auto mt-6">
      <CardHeader>
        <CardTitle class="flex items-center">
          <FileText class="mr-2" /> 证书管理
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div>
            <Input 
              v-model="newCertificate.name" 
              placeholder="证书名称" 
              class="mb-2"
            />
            <Input 
              v-model="newCertificate.issuer" 
              placeholder="颁发机构" 
              class="mb-2"
            />
            <div class="flex space-x-2">
              <Input 
                type="date" 
                v-model="newCertificate.date"
                class="flex-grow"
              />
              <Button @click="addCertificate">
                <PlusCircle class="mr-2 h-4 w-4" /> 添加
              </Button>
            </div>
            <Select v-model="newCertificate.type" class="mt-2">
              <SelectTrigger>
                <SelectValue placeholder="选择证书类型" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="专业认证">专业认证</SelectItem>
                <SelectItem value="语言能力">语言能力</SelectItem>
                <SelectItem value="其他">其他</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="bg-gray-50 p-4 rounded-lg">
            <h4 class="text-sm text-gray-600 mb-2">证书统计</h4>
            <div class="grid grid-cols-2 gap-2">
              <div class="bg-blue-100 p-3 rounded text-center">
                <p class="text-xl font-bold text-blue-600">
                  {{ certificateStore.certificateCount }}
                </p>
                <p class="text-xs text-gray-600">总证书数</p>
              </div>
              <div class="bg-green-100 p-3 rounded text-center">
                <p class="text-xl font-bold text-green-600">
                  {{ certificateStore.certificatesByType('专业认证').length }}
                </p>
                <p class="text-xs text-gray-600">专业认证</p>
              </div>
            </div>
          </div>
        </div>

        <table class="w-full border-collapse">
          <thead>
            <tr class="bg-gray-100">
              <th class="border p-2 text-left">证书名称</th>
              <th class="border p-2 text-left">颁发机构</th>
              <th class="border p-2 text-left">获取日期</th>
              <th class="border p-2 text-left">证书类型</th>
              <th class="border p-2 text-center">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr 
              v-for="cert in certificateStore.certificates" 
              :key="cert.id" 
              class="hover:bg-gray-50"
            >
              <td class="border p-2">{{ cert.name }}</td>
              <td class="border p-2">{{ cert.issuer }}</td>
              <td class="border p-2">{{ cert.date }}</td>
              <td class="border p-2">
                <span 
                  class="px-2 py-1 rounded text-xs bg-blue-100 text-blue-600"
                >
                  {{ cert.type }}
                </span>
              </td>
              <td class="border p-2 text-center">
                <AlertDialog>
                  <AlertDialogTrigger as-child>
                    <Button variant="ghost" size="sm" class="mr-1">
                      <Upload class="h-4 w-4" />
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>上传证书</AlertDialogTitle>
                      <AlertDialogDescription>
                        请选择证书文件上传
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <div class="grid gap-4 py-4">
                      <Input 
                        type="file" 
                        @change="handleFileUpload($event, cert.id)"
                      />
                    </div>
                    <AlertDialogFooter>
                      <AlertDialogCancel>取消</AlertDialogCancel>
                      <AlertDialogAction>确认上传</AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
                <Button 
                  variant="ghost" 
                  size="sm" 
                  @click="removeCertificate(cert.id)"
                >
                  <Trash2 class="h-4 w-4 text-red-500" />
                </Button>
              </td>
            </tr>
          </tbody>
        </table>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { 
  FileText, 
  PlusCircle, 
  Upload, 
  Trash2 
} from 'lucide-vue-next';
import { useCertificateStore } from '@/stores/certificate';
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

// 证书存储
const certificateStore = useCertificateStore();

// 新证书数据
const newCertificate = ref({
  name: '',
  issuer: '',
  date: '',
  type: ''
});

const loading = ref(false);
const error = ref('');

// 添加证书
const addCertificate = async () => {
  try {
    // 验证输入
    const { name, issuer, date, type } = newCertificate.value;
    if (!name || !issuer || !date || !type) {
      error.value = '请填写所有证书信息';
      return;
    }

    loading.value = true;
    await certificateStore.addCertificate({
      name,
      issuer,
      date,
      type,
      fileUrl: null
    });

    // 重置表单
    newCertificate.value = {
      name: '',
      issuer: '',
      date: '',
      type: ''
    };
  } catch (e) {
    error.value = '添加证书失败，请重试';
  } finally {
    loading.value = false;
  }
};

// 删除证书
const removeCertificate = async (id: number) => {
  try {
    loading.value = true;
    await certificateStore.removeCertificate(id);
  } catch (e) {
    error.value = '删除证书失败，请重试';
  } finally {
    loading.value = false;
  }
};

// 文件上传处理
const handleFileUpload = async (event: Event, certId: number) => {
  const input = event.target as HTMLInputElement;
  if (!input.files?.length) return;
  
  const file = input.files[0];
  
  // 文件验证逻辑保持不变
  const maxSize = 5 * 1024 * 1024;
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];

  if (file.size > maxSize) {
    error.value = '文件大小不能超过5MB';
    return;
  }

  if (!allowedTypes.includes(file.type)) {
    error.value = '仅支持JPG、PNG和PDF格式';
    return;
  }

  try {
    loading.value = true;
    // 创建 FormData 用于文件上传
    const formData = new FormData();
    formData.append('file', file);
    formData.append('certificateId', certId.toString());

    await certificateStore.uploadCertificateFile(formData);
  } catch (e) {
    error.value = '文件上传失败，请重试';
  } finally {
    loading.value = false;
  }
};
</script>
