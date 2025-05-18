import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

public class SimpleQianwenTest {

    private final String apiKey = "sk-6ceb7795be7c4dcc83ed8b1918e8a550";
    private final String apiUrl = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

    @Test
    public void testSimpleRequest() {
        try {
            // 创建请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            // 创建请求体 - 直接使用Map而不是自定义类
            Map<String, Object> requestBody = Map.of(
                    "model", "qwen-plus",
                    "input", Map.of("prompt", "你好，请生成一个简单的问候。"),
                    "task", "text_generation",  // 关键字段
                    "parameters", Map.of(
                            "temperature", 0.4,
                            "max_tokens", 100
                    )
            );

            // 打印请求体JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String requestJson = objectMapper.writeValueAsString(requestBody);
            System.out.println("请求体: " + requestJson);

            // 创建HTTP实体
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);

            // 发送请求
            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.postForObject(apiUrl, requestEntity, String.class);

            // 打印响应
            System.out.println("API响应: " + response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 如果上面的测试成功，可以尝试使用自定义类
    @Test
    public void testWithCustomClass() {
        try {
            // 创建请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            // 创建请求对象
            SimpleRequest request = new SimpleRequest();
            request.setModel("qwen-plus");
            request.setInput(new SimpleInput("你好，请生成一个简单的问候。"));
            // task已在类中设置默认值

            // 打印请求体JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String requestJson = objectMapper.writeValueAsString(request);
            System.out.println("自定义类请求体: " + requestJson);

            // 创建HTTP实体
            HttpEntity<SimpleRequest> requestEntity = new HttpEntity<>(request, headers);

            // 发送请求
            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.postForObject(apiUrl, requestEntity, String.class);

            // 打印响应
            System.out.println("API响应: " + response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Data
    public static class SimpleRequest {
        private String model;
        private SimpleInput input;

        @JsonProperty(value = "task", required = true) // 强制包含此字段
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
}