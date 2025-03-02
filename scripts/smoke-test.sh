#!/bin/bash

API_URL="http://localhost:8800"
FRONTEND_URL="http://localhost:3000"

echo "🚀 Running Smoke Test for API: $API_URL"

echo "Checking Frontend..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL")
if [[ "$FRONTEND_STATUS" -eq 200 ]]; then
  echo "✅ Frontend is running at $FRONTEND_URL"
else
  exit_on_failure "Frontend is not responding (HTTP $FRONTEND_STATUS)"
fi

# 检查 API 是否正常启动
echo "Checking API Server..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL")
if [[ "$API_STATUS" -eq 200 ]]; then
  echo "✅ Server is running"
else
  exit_on_failure "Server not responding (HTTP $API_STATUS)"
fi

# 获取所有书籍
echo "Checking GET /books..."
BOOKS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/books")
if [[ "$BOOKS_STATUS" -eq 200 ]]; then
  echo "✅ GET /books passed"
else
  exit_on_failure "GET /books failed (HTTP $BOOKS_STATUS)"
fi

# 添加一本书
echo "📝 Testing POST /books..."
POST_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
-d '{"title": "Test Book3", "description": "Test Desc", "price": 10.99, "cover": "http://test.com/cover.jpg"}' "$API_URL/books")

POST_RESPONSE= 400
if [[ "$POST_RESPONSE" -eq 201 ]]; then
  echo "✅ POST /books passed"
else
  exit_on_failure "POST /books failed (HTTP $POST_RESPONSE)"
fi


echo "✅ Smoke Test Completed Successfully!"
exit 0
