import { defineStore } from 'pinia';

interface Certificate {
  id: number;
  name: string;
  issuer: string;
  date: string;
  type: string;
  fileUrl: string | null;
}

interface CertificateInput {
  name: string;
  issuer: string;
  date: string;
  type: string;
  fileUrl?: string | null;
}

export const useCertificateStore = defineStore('certificate', {
  state: () => ({
    certificates: [] as Certificate[],
    loading: false,
    error: null as string | null
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
    // 获取所有证书
    async fetchCertificates() {
      try {
        this.loading = true;
        this.error = null;
        
        const response = await fetch('/api/certificates');
        if (!response.ok) throw new Error('获取证书列表失败');
        
        const data = await response.json();
        this.certificates = data;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '获取证书失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 添加证书
    async addCertificate(certificate: CertificateInput) {
      try {
        this.loading = true;
        this.error = null;
        
        const response = await fetch('/api/certificates', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(certificate),
        });

        if (!response.ok) throw new Error('添加证书失败');
        
        const newCertificate = await response.json();
        this.certificates.push(newCertificate);
        return newCertificate;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '添加证书失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 更新证书
    async updateCertificate(id: number, updates: Partial<CertificateInput>) {
      try {
        this.loading = true;
        this.error = null;
        
        const response = await fetch(`/api/certificates/${id}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(updates),
        });

        if (!response.ok) throw new Error('更新证书失败');
        
        const updatedCertificate = await response.json();
        const index = this.certificates.findIndex(c => c.id === id);
        if (index !== -1) {
          this.certificates[index] = updatedCertificate;
        }
      } catch (error) {
        this.error = error instanceof Error ? error.message : '更新证书失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 删除证书
    async removeCertificate(id: number) {
      try {
        this.loading = true;
        this.error = null;
        
        const response = await fetch(`/api/certificates/${id}`, {
          method: 'DELETE',
        });

        if (!response.ok) throw new Error('删除证书失败');
        
        this.certificates = this.certificates.filter(cert => cert.id !== id);
      } catch (error) {
        this.error = error instanceof Error ? error.message : '删除证书失败';
        throw error;
      } finally {
        this.loading = false;
      }
    },

    // 上传证书文件
    async uploadCertificateFile(id: number, file: File) {
      try {
        this.loading = true;
        this.error = null;

        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(`/api/certificates/${id}/upload`, {
          method: 'POST',
          body: formData,
        });

        if (!response.ok) throw new Error('上传文件失败');
        
        const { fileUrl } = await response.json();
        await this.updateCertificate(id, { fileUrl });
        return fileUrl;
      } catch (error) {
        this.error = error instanceof Error ? error.message : '上传文件失败';
        throw error;
      } finally {
        this.loading = false;
      }
    }
  }
});
