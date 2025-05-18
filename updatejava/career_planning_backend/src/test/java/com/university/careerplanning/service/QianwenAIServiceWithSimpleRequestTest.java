import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.university.careerplanning.dto.CareerPlanRequest;
import com.university.careerplanning.dto.CareerPlanResponse;
import com.university.careerplanning.service.QianwenAIService;
import lombok.Data;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class QianwenAIServiceWithSimpleRequestTest {
    private static final Logger logger = LoggerFactory.getLogger(QianwenAIServiceWithSimpleRequestTest.class);

    @Mock
    private RestTemplate restTemplate;

    @Spy
    private ObjectMapper objectMapper;

    @InjectMocks
    private QianwenAIService qianwenAIService;

    private final String apiKey = "sk-6ceb7795be7c4dcc83ed8b1918e8a550";
    private final String apiUrl = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

    @Test
    void testGeneratePersonalizedPlanWithSimpleRequest() {
        try {
            // 设置QianwenAIService的字段值
            ReflectionTestUtils.setField(qianwenAIService, "qianwenApiKey", apiKey);
            ReflectionTestUtils.setField(qianwenAIService, "qianwenApiUrl", apiUrl);
            ReflectionTestUtils.setField(qianwenAIService, "modelName", "qwen-plus");

            // 创建CareerPlanRequest对象
            CareerPlanRequest request = new CareerPlanRequest();
            request.setSelectedCareer(1); // 前端开发工程师
            request.setPlanDuration("medium");
            request.setSkillLevel("intermediate");
            request.setWeeklyStudyHours("medium");
            request.setInterests(Arrays.asList(1, 3));

            // 创建SimpleRequest对象，模拟通义千问API请求
            SimpleRequest simpleRequest = new SimpleRequest();
            simpleRequest.setModel("qwen-plus");

            // 这里我们创建一个mock的SimpleResponse对象
            SimpleResponse mockResponse = new SimpleResponse();
            SimpleOutput output = new SimpleOutput();
            output.setText("```json\n" +
                    "{\n" +
                    "  \"targetCareer\": \"前端开发工程师\",\n" +
                    "  \"careerPath\": \"初级前端 → 中级前端 → 高级前端\",\n" +
                    "  \"estimatedTime\": \"2-3年\",\n" +
                    "  \"semesters\": [\n" +
                    "    {\n" +
                    "      \"semester\": \"大二上\",\n" +
                    "      \"skills\": [\n" +
                    "        {\n" +
                    "          \"name\": \"HTML/CSS\",\n" +
                    "          \"semesterGoal\": \"掌握HTML5和CSS3基础\",\n" +
                    "          \"status\": \"进行中\"\n" +
                    "        }\n" +
                    "      ]\n" +
                    "    }\n" +
                    "  ]\n" +
                    "}\n" +
                    "```");
            mockResponse.setOutput(output);

            // 修改restTemplate.postForObject的行为，无论传入什么参数，都返回我们的mockResponse
            when(restTemplate.postForObject(
                    anyString(),  // 匹配任何URL
                    any(),  // 匹配任何请求体
                    eq(QianwenAIService.QianwenResponse.class)  // 匹配响应类型
            )).thenAnswer(invocation -> {
                // 获取HttpEntity实参
                HttpEntity<?> requestEntity = invocation.getArgument(1);
                Object body = requestEntity.getBody();

                // 打印请求体，查看是否包含task字段
                ObjectMapper mapper = new ObjectMapper();
                String requestJson = mapper.writeValueAsString(body);
                logger.info("发送到通义千问API的请求体: {}", requestJson);

                // 将SimpleResponse转换为QianwenAIService.QianwenResponse
                QianwenAIService.QianwenResponse qResponse = convertToQianwenResponse(mockResponse);
                return qResponse;
            });

            // 调用被测试的方法
            CareerPlanResponse response = qianwenAIService.generatePersonalizedPlan(request);

            // 验证结果
            assertNotNull(response, "职业规划响应不应为空");
            assertEquals("前端开发工程师", response.getTargetCareer(), "目标职业应匹配");
            assertEquals("2-3年", response.getEstimatedTime(), "预计时间应匹配");
            assertNotNull(response.getSemesters(), "学期规划不应为空");
            assertFalse(response.getSemesters().isEmpty(), "应有至少一个学期");

            // 打印详细信息
            logger.info("职业规划响应: {}", response);
        } catch (Exception e) {
            logger.error("测试异常", e);
            fail("测试过程中发生异常: " + e.getMessage());
        }
    }

    // 将SimpleResponse转换为QianwenAIService.QianwenResponse
    private QianwenAIService.QianwenResponse convertToQianwenResponse(SimpleResponse simpleResponse) throws Exception {
        // 使用反射创建QianwenAIService.QianwenResponse和QianwenAIService.QianwenOutput实例
        Class<?> responseClass = Class.forName("com.university.careerplanning.service.QianwenAIService$QianwenResponse");
        Class<?> outputClass = Class.forName("com.university.careerplanning.service.QianwenAIService$QianwenOutput");

        Object qResponse = responseClass.getDeclaredConstructor().newInstance();
        Object qOutput = outputClass.getDeclaredConstructor().newInstance();

        // 设置text字段
        outputClass.getDeclaredMethod("setText", String.class).invoke(qOutput, simpleResponse.getOutput().getText());

        // 将output设置到response
        responseClass.getDeclaredMethod("setOutput", outputClass).invoke(qResponse, qOutput);

        return (QianwenAIService.QianwenResponse) qResponse;
    }

    // 用于测试的简单请求类
    @Data
    public static class SimpleRequest {
        private String model;
        private SimpleInput input;

        @JsonProperty(value = "task", required = true)
        private String task = "text_generation";

        private Map<String, Object> parameters = Map.of(
                "temperature", 0.4,
                "max_tokens", 100
        );
    }

    @Data
    public static class SimpleInput {
        private String prompt;

        public SimpleInput(String prompt) {
            this.prompt = prompt;
        }
    }

    // 用于测试的简单响应类
    @Data
    public static class SimpleResponse {
        private SimpleOutput output;
    }

    @Data
    public static class SimpleOutput {
        private String text;
    }
}