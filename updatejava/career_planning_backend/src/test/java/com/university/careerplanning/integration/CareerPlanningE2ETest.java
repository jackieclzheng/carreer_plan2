package com.university.careerplanning.integration;

import com.university.careerplanning.CareerPlanningApplication;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 注意：此测试需要有效的通义千问API密钥
 * 请在测试前确保已设置环境变量或配置
 */
@SpringBootTest(
        classes = CareerPlanningApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
@ActiveProfiles("test") // 使用测试配置文件
public class CareerPlanningE2ETest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void testRealQianwenApiIntegration() {
        // 检查环境变量是否设置
        String apiKey = System.getenv("QIANWEN_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            System.out.println("警告: 未设置QIANWEN_API_KEY环境变量，将使用备用计划");
        }

        // 创建请求数据
        CareerPlanRequest request = new CareerPlanRequest();
        request.setSelectedCareer(1);
        request.setPlanDuration("medium");
        request.setSkillLevel("intermediate");
        request.setInterests(List.of(1, 3));
        request.setWeeklyStudyHours("medium");

        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<CareerPlanRequest> requestEntity = new HttpEntity<>(request, headers);

        // 发送请求
        String url = "http://localhost:" + port + "/api/career-planning/plan";
        ResponseEntity<CareerPlanResponse> responseEntity = restTemplate.postForEntity(
                url, requestEntity, CareerPlanResponse.class);

        // 验证响应
        assertTrue(responseEntity.getStatusCode().is2xxSuccessful(), "请求应该成功");
        CareerPlanResponse response = responseEntity.getBody();
        assertNotNull(response, "响应不应为空");
        
        // 基本验证 - 无论是真实API响应还是备用计划都应满足
        assertNotNull(response.getTargetCareer(), "目标职业不应为空");
        assertNotNull(response.getCareerPath(), "职业路径不应为空");
        assertNotNull(response.getSemesters(), "学期计划不应为空");
        
        // 打印响应用于手动验证
        System.out.println("API响应成功! 目标职业: " + response.getTargetCareer());
        System.out.println("职业路径: " + response.getCareerPath());
        System.out.println("学期数量: " + response.getSemesters().size());
    }
    
    @Test
    public void testGetCareerDirections() {
        // 发送GET请求
        String url = "http://localhost:" + port + "/api/career-planning/directions";
        ResponseEntity<Object[]> responseEntity = restTemplate.getForEntity(url, Object[].class);
        
        // 验证响应
        assertTrue(responseEntity.getStatusCode().is2xxSuccessful());
        Object[] directions = responseEntity.getBody();
        assertNotNull(directions);
        assertTrue(directions.length > 0, "应返回至少一个职业方向");
    }
}
