package com.university.careerplanning.controller;

import com.university.careerplanning.config.JwtTokenProvider;
import com.university.careerplanning.dto.AuthRequest;
import com.university.careerplanning.dto.AuthResponse;
import com.university.careerplanning.model.User;
import com.university.careerplanning.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/auth")
public class AdminAuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateAdmin(@Valid @RequestBody AuthRequest loginRequest) {
        try {
            // 首先验证用户名密码
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            // 检查是否是管理员账号（这里简单地用用户名判断）
            if (!"admin".equals(loginRequest.getUsername())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("非管理员账号无法登录");
            }

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = jwtTokenProvider.generateToken((UserDetails) authentication.getPrincipal());

            User user = userService.findByUsername(loginRequest.getUsername())
                    .orElseThrow(() -> new RuntimeException("用户不存在"));

            // 为管理员创建带有特殊标记的响应
            return ResponseEntity.ok(new AuthResponse(jwt, user.getId(), user.getUsername(), user.getEmail(), true));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("登录失败: " + e.getMessage());
        }
    }
}