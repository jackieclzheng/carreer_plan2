
package com.university.careerplanning.controller;

import com.university.careerplanning.dto.CertificateDTO;
import com.university.careerplanning.model.Certificate;
import com.university.careerplanning.service.CertificateService;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/certificates")
public class CertificateController {

    @Autowired
    private CertificateService certificateService;
    
    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<CertificateDTO>> getCertificates(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        List<Certificate> certificates = certificateService.getCertificatesByUserId(userId);
        
        List<CertificateDTO> certificateDTOs = certificates.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(certificateDTOs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CertificateDTO> getCertificateById(@PathVariable Long id) {
        Certificate certificate = certificateService.getCertificateById(id);
        return ResponseEntity.ok(convertToDTO(certificate));
    }

    @PostMapping
    public ResponseEntity<CertificateDTO> createCertificate(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CertificateDTO certificateDTO) {
        
        Long userId = userService.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("用户未找到"))
                .getId();
        
        Certificate certificate = convertToEntity(certificateDTO);
        Certificate savedCertificate = certificateService.createCertificate(userId, certificate);
        
        return ResponseEntity.ok(convertToDTO(savedCertificate));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CertificateDTO> updateCertificate(
            @PathVariable Long id,
            @Valid @RequestBody CertificateDTO certificateDTO) {
        
        Certificate certificate = convertToEntity(certificateDTO);
        Certificate updatedCertificate = certificateService.updateCertificate(id, certificate);
        
        return ResponseEntity.ok(convertToDTO(updatedCertificate));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCertificate(@PathVariable Long id) {
        certificateService.deleteCertificate(id);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/upload")
    public ResponseEntity<?> uploadCertificateFile(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) throws IOException {
        
        // 这里应该实现文件存储逻辑，如将文件保存到文件系统或云存储
        // 简化示例：只返回成功消息和模拟的文件URL
        String fileUrl = "/uploads/certificates/" + id + "_" + file.getOriginalFilename();
        
        return ResponseEntity.ok(new FileUploadResponse(fileUrl));
    }
    
    // 辅助方法：将实体转换为DTO
    private CertificateDTO convertToDTO(Certificate certificate) {
        CertificateDTO dto = new CertificateDTO();
        dto.setId(certificate.getId());
        dto.setName(certificate.getName());
        dto.setIssuer(certificate.getIssuer());
        
        // 格式化日期为字符串
        if (certificate.getIssueDate() != null) {
            dto.setDate(certificate.getIssueDate().format(DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        // 设置类型（在DTO中添加type字段）
        dto.setType(certificate.getDescription() != null ? certificate.getDescription() : "专业认证");
        
        // 文件URL可能需要从其他地方获取
        dto.setFileUrl(null);
        
        return dto;
    }
    
    // 辅助方法：将DTO转换为实体
    private Certificate convertToEntity(CertificateDTO dto) {
        Certificate certificate = new Certificate();
        
        if (dto.getId() != null) {
            certificate.setId(dto.getId());
        }
        
        certificate.setName(dto.getName());
        certificate.setIssuer(dto.getIssuer());
        
        // 解析日期字符串
        if (dto.getDate() != null && !dto.getDate().isEmpty()) {
            certificate.setIssueDate(LocalDate.parse(dto.getDate(), DateTimeFormatter.ISO_LOCAL_DATE));
        }
        
        // 将type字段存储到description
        if (dto.getType() != null) {
            certificate.setDescription(dto.getType());
        }
        
        return certificate;
    }
    
    // 文件上传响应类
    public static class FileUploadResponse {
        private String fileUrl;
        
        public FileUploadResponse(String fileUrl) {
            this.fileUrl = fileUrl;
        }
        
        public String getFileUrl() {
            return fileUrl;
        }
    }
}

