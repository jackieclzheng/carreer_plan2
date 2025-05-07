import { defineStore } from 'pinia';
import type { Certificate } from '@/types';

export const useCertificateStore = defineStore('certificate', {
  state: () => ({
    certificates: [
      {
        id: 1,
        name: '计算机等级考试二级',
        issuer: '中国计算机协会',
        date: '2023-06-15',
        type: '专业认证',
        fileUrl: null
      },
      {
        id: 2,
        name: '英语四级证书',
        issuer: '教育部',
        date: '2023-12-10',
        type: '语言能力',
        fileUrl: null
      }
    ]
  }),

  getters: {
    certificatesByType() {
      return (type: string) => {
        return this.certificates.filter(cert => cert.type === type);
      };
    },

    certificateCount() {
      return this.certificates.length;
    }
  },

  actions: {
    // 添加新证书
    addCertificate(certificate: Omit<Certificate, 'id'>) {
      const newCertificate = {
        ...certificate,
        id: this.certificates.length + 1
      };
      this.certificates.push(newCertificate);
    },

    // 删除证书
    removeCertificate(id: number) {
      const index = this.certificates.findIndex(cert => cert.id === id);
      if (index !== -1) {
        this.certificates.splice(index, 1);
      }
    },

    // 更新证书
    updateCertificate(id: number, updatedCertificate: Partial<Certificate>) {
      const index = this.certificates.findIndex(cert => cert.id === id);
      if (index !== -1) {
        this.certificates[index] = {
          ...this.certificates[index],
          ...updatedCertificate
        };
      }
    }
  }
});
