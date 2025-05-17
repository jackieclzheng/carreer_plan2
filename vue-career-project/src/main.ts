import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// 全局样式
import './styles/global.css'

// 初始化检查 - 确保本地存储和认证状态一致
const token = localStorage.getItem('token');
const user = localStorage.getItem('user');

// 输出启动状态
console.log('应用启动:', {
  token存在: !!token,
  user存在: !!user,
  当前路径: window.location.pathname
});

// 创建 Pinia 实例
const pinia = createPinia();

// 创建并挂载应用
const app = createApp(App);
app.use(pinia);
app.use(router);
app.mount('#app');