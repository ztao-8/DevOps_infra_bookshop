#!/bin/bash

API_URL="http://localhost:8800"

echo "🚀 Running Smoke Test for API: $API_URL"

echo "🖥️  Checking Frontend..."
curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" | grep 200 > /dev/null && \
echo "✅ Frontend is running at $FRONTEND_URL" || \
echo "❌ Frontend is not responding"

# 检查 API 是否正常启动
curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep 200 > /dev/null && echo "✅ Server is running" || echo "❌ Server not responding"

# 获取所有书籍
curl -s -o /dev/null -w "%{http_code}" "$API_URL/books" | grep 200 > /dev/null && echo "✅ GET /books passed" || echo "❌ GET /books failed"

# 添加一本书
curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"title": "Test Book3", "description": "Test Desc", "price": 10.99, "cover": "http://test.com/cover.jpg"}' "$API_URL/books" | grep 200> /dev/null && echo "✅ POST /books passed" || echo "❌ POST /books failed"

echo "✅ Smoke Test Completed!"
