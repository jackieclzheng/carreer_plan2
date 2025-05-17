#!/bin/bash

# 设置环境变量
export QIANWEN_API_KEY="your_api_key_here"

# 编译项目
echo "编译项目..."
./mvnw clean package -DskipTests

# 运行应用
echo "启动应用..."
java -jar target/career-planning-platform-1.0.0.jar
