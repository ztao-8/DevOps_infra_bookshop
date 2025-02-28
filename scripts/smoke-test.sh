#!/bin/bash

EC2_IP=$1  # 获取传入的 IP 参数
API_URL="http://$EC2_IP:8800"

echo "🚀 Running Smoke Test for API: $API_URL"

# 检查 API 是否正常启动
curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep 200 > /dev/null && echo "✅ Server is running" || echo "❌ Server not responding"

# 获取所有书籍
curl -s -o /dev/null -w "%{http_code}" "$API_URL/books" | grep 200 > /dev/null && echo "✅ GET /books passed" || echo "❌ GET /books failed"

# 添加一本书
curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"title": "Test Book", "description": "Test Desc", "price": 10.99, "cover": "http://test.com/cover.jpg"}' "$API_URL/books" | grep 201 > /dev/null && echo "✅ POST /books passed" || echo "❌ POST /books failed"

echo "✅ Smoke Test Completed!"
