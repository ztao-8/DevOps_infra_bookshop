#!/bin/bash

# 确保传递 TEMP_IP，否则退出
if [ -z "$1" ]; then
  echo "❌ Error: Missing argument for TEMP_IP."
  echo "Usage: ./smoke-test.sh <TEMP_IP>"
  exit 1
fi

TEMP_IP=$1
API_URL="http://$TEMP_IP:8800"
FRONTEND_URL="http://$TEMP_IP:3000"

echo "🚀 Running Smoke Test for API: $API_URL"

# 退出函数
exit_on_failure() {
  echo "❌ $1"
  exit 1
}

echo "Checking Frontend..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL")
if [[ "$FRONTEND_STATUS" -eq 200 ]]; then
  echo "✅ Frontend is running at $FRONTEND_URL"
else
  exit_on_failure "Frontend is not responding (HTTP $FRONTEND_STATUS)"
fi

echo "Checking API Server..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL")
if [[ "$API_STATUS" -eq 200 ]]; then
  echo "✅ Server is running"
else
  exit_on_failure "Server not responding (HTTP $API_STATUS)"
fi

echo "Checking GET /books..."
DATA=$(curl -s "$API_URL/books")

if [[ -z "$DATA" ]]; then
  exit_on_failure "GET /books failed: No data received"
fi

echo "Validating JSON response..."
echo "$DATA" | jq empty 2>/dev/null
if [[ $? -ne 0 ]]; then
  exit_on_failure "GET /books failed: Invalid JSON response"
fi

COUNT=$(echo "$DATA" | jq '. | length')
echo "Number of books: $COUNT"
echo "✅ GET /books passed"

# add a new book
echo "📝 Testing POST /books..."
POST_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
-d '{"title": "Test Book", "description": "Test Desc", "price": 10.99, "cover": "http://test.com/cover.jpg"}' "$API_URL/books")

if [[ "$POST_RESPONSE" -eq 201 ]]; then
  echo "✅ POST /books passed"
else
  exit_on_failure "POST /books failed (HTTP $POST_RESPONSE)"
fi

#check new book successfully show up
echo "Checking GET /books..."
DATA=$(curl -s "$API_URL/books")

if [[ -z "$DATA" ]]; then
  exit_on_failure "GET /books failed: No data received"
fi

echo "Validating JSON response..."
echo "$DATA" | jq empty 2>/dev/null
if [[ $? -ne 0 ]]; then
  exit_on_failure "GET /books failed: Invalid JSON response"
fi

COUNT=$(echo "$DATA" | jq '. | length')
echo "Number of books: $COUNT"
if [ "$COUNT" -eq 4 ]; then
  echo "✅ Integration test passed"
else
  exit_on_failure "Integration failed"
fi


echo "✅ Smoke Test Completed Successfully!"
exit 0
