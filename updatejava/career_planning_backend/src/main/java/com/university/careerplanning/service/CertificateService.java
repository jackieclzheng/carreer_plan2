
package com.university.careerplanning.service;

import com.university.careerplanning.exception.ResourceNotFoundException;
import com.university.careerplanning.model.Certificate;
import com.university.careerplanning.model.User;
import com.university.careerplanning.repository.CertificateRepository;
import com.university.careerplanning.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class CertificateService {

    @Autowired
    private CertificateRepository certificateRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Certificate> getCertificatesByUserId(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        return certificateRepository.findByUser(user);
    }

    public Certificate getCertificateById(Long certificateId) {
        return certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
    }

    @Transactional
    public Certificate createCertificate(Long userId, Certificate certificate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户不存在"));
                
        certificate.setUser(user);
        
        // 转换日期字符串为LocalDate
        if (certificate.getIssueDate() == null) {
            certificate.setIssueDate(LocalDate.now());
        }
        
        return certificateRepository.save(certificate);
    }

    @Transactional
    public Certificate updateCertificate(Long certificateId, Certificate updatedCertificate) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
                
        // 更新字段
        certificate.setName(updatedCertificate.getName());
        certificate.setIssuer(updatedCertificate.getIssuer());
        
        if (updatedCertificate.getIssueDate() != null) {
            certificate.setIssueDate(updatedCertificate.getIssueDate());
        }
        
        if (updatedCertificate.getExpiryDate() != null) {
            certificate.setExpiryDate(updatedCertificate.getExpiryDate());
        }
        
        if (updatedCertificate.getDescription() != null) {
            certificate.setDescription(updatedCertificate.getDescription());
        }
        
        return certificateRepository.save(certificate);
    }

    @Transactional
    public void deleteCertificate(Long certificateId) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new ResourceNotFoundException("证书不存在"));
                
        certificateRepository.delete(certificate);
    }
}

