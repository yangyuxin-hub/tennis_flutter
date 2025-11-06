# Tennis-Frog 后端API设置文档

> 项目名称：Tennis-Frog 网球社交平台  
> API版本：v1.0  
> 技术栈：FastAPI + Python 3.10+  
> 更新日期：2025-11-06

---

## 📋 目录

1. [API概述](#api概述)
2. [基础配置](#基础配置)
3. [API规范](#api规范)
4. [认证机制](#认证机制)
5. [API端点详细说明](#api端点详细说明)
6. [错误处理](#错误处理)
7. [开发环境配置](#开发环境配置)
8. [部署配置](#部署配置)
9. [测试指南](#测试指南)
10. [安全规范](#安全规范)

---

## API概述

### 技术栈

- **框架**：FastAPI 0.104+
- **语言**：Python 3.10+
- **数据库**：PostgreSQL 14+
- **ORM**：SQLAlchemy 2.0+
- **认证**：JWT (PyJWT)
- **验证码服务**：阿里云短信 / 腾讯云短信
- **文档**：Swagger UI / ReDoc

### API版本

- **当前版本**：v1
- **基础路径**：`/api/v1`
- **版本控制**：URL路径版本控制

### 设计原则

1. **RESTful风格**：遵循REST API设计规范
2. **统一响应格式**：所有接口使用统一的响应结构
3. **JWT认证**：使用JWT Token进行身份认证
4. **错误处理**：统一的错误码和错误消息
5. **API文档**：自动生成Swagger文档

---

## 基础配置

### 环境变量配置

创建 `.env` 文件：

```env
# 应用配置
APP_NAME=Tennis-Frog API
APP_VERSION=1.0.0
DEBUG=True
SECRET_KEY=your-secret-key-here-change-in-production

# 数据库配置
DATABASE_URL=postgresql://user:password@localhost:5432/tennis_frog
DATABASE_POOL_SIZE=20
DATABASE_MAX_OVERFLOW=10

# JWT配置
JWT_SECRET_KEY=your-jwt-secret-key-here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=120  # 2小时
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30     # 30天

# 短信服务配置（阿里云）
SMS_ACCESS_KEY_ID=your-access-key-id
SMS_ACCESS_KEY_SECRET=your-access-key-secret
SMS_SIGN_NAME=网球社交平台
SMS_TEMPLATE_CODE=SMS_123456789

# Redis配置（可选，用于缓存和限流）
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# CORS配置
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
CORS_ALLOW_CREDENTIALS=True

# 文件存储配置（OSS）
OSS_ENDPOINT=oss-cn-beijing.aliyuncs.com
OSS_ACCESS_KEY_ID=your-oss-access-key-id
OSS_ACCESS_KEY_SECRET=your-oss-access-key-secret
OSS_BUCKET_NAME=tennis-frog
OSS_BASE_URL=https://cdn.tennis.yourdomain.com

# 日志配置
LOG_LEVEL=INFO
LOG_FILE=logs/api.log
```

### 项目结构

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI应用入口
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py          # 配置管理
│   │   ├── security.py        # JWT和安全工具
│   │   └── database.py        # 数据库连接
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py            # 用户模型
│   │   ├── session.py         # 会话模型
│   │   └── sms_code.py        # 验证码模型
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py            # 用户Schema
│   │   ├── auth.py            # 认证Schema
│   │   └── common.py          # 通用Schema
│   ├── api/
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py        # 认证路由
│   │   │   └── users.py       # 用户路由
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py    # 认证服务
│   │   ├── sms_service.py     # 短信服务
│   │   └── user_service.py   # 用户服务
│   └── utils/
│       ├── __init__.py
│       └── exceptions.py      # 异常处理
├── requirements.txt
├── .env
└── README.md
```

---

## API规范

### 请求格式

#### Content-Type
- **JSON请求**：`application/json`
- **文件上传**：`multipart/form-data`

#### 请求头

```http
Content-Type: application/json
Authorization: Bearer {access_token}  # 需要认证的接口
Accept: application/json
```

### 响应格式

#### 成功响应

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    // 响应数据
  }
}
```

#### 错误响应

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": {}  // 可选，详细错误信息
  }
}
```

### HTTP状态码

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| 200 | OK | 请求成功 |
| 201 | Created | 创建成功 |
| 400 | Bad Request | 请求参数错误 |
| 401 | Unauthorized | 未认证或Token无效 |
| 403 | Forbidden | 无权限 |
| 404 | Not Found | 资源不存在 |
| 429 | Too Many Requests | 请求频率过高 |
| 500 | Internal Server Error | 服务器错误 |

---

## 认证机制

### JWT Token认证

#### Token类型

1. **Access Token**（访问令牌）
   - 有效期：2小时
   - 用途：API请求认证
   - 存储位置：请求头 `Authorization: Bearer {token}`

2. **Refresh Token**（刷新令牌）
   - 有效期：30天
   - 用途：刷新Access Token
   - 存储位置：请求体或请求头

#### Token生成

```python
import jwt
from datetime import datetime, timedelta

def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire, "iat": datetime.utcnow()})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
```

#### Token验证

```python
def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token已过期")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token无效")
```

### 认证依赖注入

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    payload = verify_token(token)
    user_id = payload.get("sub")
    # 从数据库获取用户
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return user
```

---

## API端点详细说明

### 1. 发送短信验证码

**接口地址**：`POST /api/v1/auth/send-sms-code`

**认证要求**：无需认证

**请求参数**：

```json
{
  "phone": "15257854295",
  "country_code": "+86",
  "device_info": {
    "device_id": "uuid-xxx-xxx",
    "device_type": "iOS",
    "device_name": "iPhone 13",
    "os_version": "17.0"
  }
}
```

**参数说明**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `phone` | string | 是 | 手机号（8-20位） |
| `country_code` | string | 否 | 国家代码，默认"+86" |
| `device_info` | object | 是 | 设备信息 |
| `device_info.device_id` | string | 是 | 设备唯一标识 |
| `device_info.device_type` | string | 是 | 设备类型：iOS/Android/Web |
| `device_info.device_name` | string | 否 | 设备名称 |
| `device_info.os_version` | string | 否 | 操作系统版本 |

**响应示例（成功）**：

```json
{
  "success": true,
  "message": "验证码已发送",
  "data": {
    "expires_in": 300,
    "resend_after": 60,
    "code_length": 4
  }
}
```

**响应示例（错误）**：

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "发送过于频繁，请60秒后再试"
  }
}
```

**业务规则**：

1. 同一手机号60秒内只能发送一次
2. 验证码有效期5分钟
3. 验证码为4位数字
4. 记录IP地址和设备信息
5. 记录发送日志

**错误码**：

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_PHONE` | 400 | 手机号格式错误 |
| `RATE_LIMIT_EXCEEDED` | 429 | 发送频率过高 |
| `SMS_SEND_FAILED` | 500 | 短信发送失败 |

---

### 2. 验证码登录

**接口地址**：`POST /api/v1/auth/login-with-sms`

**认证要求**：无需认证

**请求参数**：

```json
{
  "phone": "15257854295",
  "country_code": "+86",
  "code": "1234",
  "device_info": {
    "device_id": "uuid-xxx-xxx",
    "device_type": "iOS",
    "device_name": "iPhone 13",
    "device_model": "iPhone14,5",
    "os_version": "17.0"
  }
}
```

**参数说明**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `phone` | string | 是 | 手机号 |
| `country_code` | string | 否 | 国家代码，默认"+86" |
| `code` | string | 是 | 4位验证码 |
| `device_info` | object | 是 | 设备信息 |

**响应示例（成功 - 老用户）**：

```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "user": {
      "id": 12345,
      "phone": "15257854295",
      "country_code": "+86",
      "username": "tennis_lover",
      "nickname": "网球爱好者",
      "avatar": "https://cdn.example.com/avatars/12345.jpg",
      "skill_level": "intermediate",
      "play_style": "baseline",
      "is_profile_completed": true,
      "is_premium": false,
      "created_at": "2024-01-15T08:30:00Z",
      "last_login_at": "2024-11-06T10:25:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "token_type": "Bearer",
      "expires_in": 7200
    }
  }
}
```

**响应示例（成功 - 新用户注册）**：

```json
{
  "success": true,
  "message": "注册并登录成功",
  "data": {
    "user": {
      "id": 12346,
      "phone": "15257854295",
      "country_code": "+86",
      "username": null,
      "nickname": null,
      "avatar": null,
      "skill_level": "beginner",
      "play_style": null,
      "is_profile_completed": false,
      "is_premium": false,
      "created_at": "2024-11-06T10:30:00Z",
      "last_login_at": "2024-11-06T10:30:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "token_type": "Bearer",
      "expires_in": 7200
    }
  }
}
```

**响应示例（错误）**：

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CODE",
    "message": "验证码错误或已过期",
    "details": {
      "attempts_remaining": 2
    }
  }
}
```

**业务规则**：

1. 验证码最多尝试3次
2. 验证码过期后无法使用
3. 验证码使用后立即失效
4. 用户不存在时自动创建新用户
5. 创建会话记录
6. 记录登录日志

**错误码**：

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_CODE` | 400 | 验证码错误 |
| `CODE_EXPIRED` | 400 | 验证码已过期 |
| `CODE_ALREADY_USED` | 400 | 验证码已使用 |
| `TOO_MANY_ATTEMPTS` | 429 | 尝试次数过多 |
| `ACCOUNT_BLOCKED` | 403 | 账号被锁定 |

---

### 3. 刷新Token

**接口地址**：`POST /api/v1/auth/refresh-token`

**认证要求**：Refresh Token

**请求参数**：

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**或使用请求头**：

```http
Authorization: Bearer {refresh_token}
```

**响应示例（成功）**：

```json
{
  "success": true,
  "message": "Token刷新成功",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 7200
  }
}
```

**响应示例（错误）**：

```json
{
  "success": false,
  "error": {
    "code": "INVALID_REFRESH_TOKEN",
    "message": "Refresh Token无效或已过期"
  }
}
```

**业务规则**：

1. Refresh Token必须有效且未过期
2. 刷新后生成新的Access Token
3. Refresh Token保持不变
4. 更新会话的last_active_at

**错误码**：

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_REFRESH_TOKEN` | 401 | Refresh Token无效 |
| `REFRESH_TOKEN_EXPIRED` | 401 | Refresh Token已过期 |

---

### 4. 用户登出

**接口地址**：`POST /api/v1/auth/logout`

**认证要求**：Access Token

**请求头**：

```http
Authorization: Bearer {access_token}
```

**请求参数**（可选）：

```json
{
  "device_id": "uuid-xxx-xxx"  // 指定设备登出，不传则登出所有设备
}
```

**响应示例（成功）**：

```json
{
  "success": true,
  "message": "登出成功"
}
```

**业务规则**：

1. 设置会话为不活跃（is_active = FALSE）
2. 如果指定device_id，只登出该设备
3. 如果不指定device_id，登出所有设备
4. 记录登出日志

---

### 5. 获取当前用户信息

**接口地址**：`GET /api/v1/users/me`

**认证要求**：Access Token

**请求头**：

```http
Authorization: Bearer {access_token}
```

**响应示例（成功）**：

```json
{
  "success": true,
  "data": {
    "id": 12345,
    "phone": "15257854295",
    "country_code": "+86",
    "username": "tennis_lover",
    "nickname": "网球爱好者",
    "avatar": "https://cdn.example.com/avatars/12345.jpg",
    "bio": "热爱网球，寻找球友一起进步！",
    "gender": "male",
    "birth_date": "1995-06-15",
    "skill_level": "intermediate",
    "play_style": "baseline",
    "favorite_court": "奥林匹克森林公园网球场",
    "racket_brand": "Wilson",
    "is_active": true,
    "is_phone_verified": true,
    "is_premium": false,
    "is_profile_completed": true,
    "created_at": "2024-01-15T08:30:00Z",
    "last_login_at": "2024-11-06T10:25:00Z"
  }
}
```

---

### 6. 更新用户资料

**接口地址**：`PATCH /api/v1/users/me`

**认证要求**：Access Token

**请求头**：

```http
Authorization: Bearer {access_token}
Content-Type: application/json
```

**请求参数**：

```json
{
  "nickname": "新昵称",
  "bio": "新的个人简介",
  "gender": "male",
  "birth_date": "1995-06-15",
  "skill_level": "advanced",
  "play_style": "all_court",
  "favorite_court": "新球场",
  "racket_brand": "新品牌"
}
```

**响应示例（成功）**：

```json
{
  "success": true,
  "message": "资料更新成功",
  "data": {
    "id": 12345,
    "nickname": "新昵称",
    "bio": "新的个人简介",
    // ... 其他字段
    "is_profile_completed": true,
    "updated_at": "2024-11-06T11:00:00Z"
  }
}
```

**业务规则**：

1. 只能更新自己的资料
2. 更新后检查资料完整度
3. 如果所有必填字段都有值，设置is_profile_completed = TRUE

---

### 7. 上传头像

**接口地址**：`POST /api/v1/users/me/avatar`

**认证要求**：Access Token

**请求头**：

```http
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**请求参数**：

```
avatar: [文件]  # 图片文件，支持jpg/png，最大5MB
```

**响应示例（成功）**：

```json
{
  "success": true,
  "message": "头像上传成功",
  "data": {
    "avatar_url": "https://cdn.example.com/avatars/12345/avatar_20241106.jpg"
  }
}
```

**业务规则**：

1. 文件格式：jpg, png
2. 文件大小：最大5MB
3. 图片尺寸：建议512x512，自动裁剪
4. 上传到OSS对象存储
5. 更新用户avatar字段

---

## 错误处理

### 统一错误响应格式

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": {
      // 可选，详细错误信息
    }
  }
}
```

### 错误码列表

#### 认证相关错误（4xx）

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_PHONE` | 400 | 手机号格式错误 |
| `INVALID_CODE` | 400 | 验证码错误 |
| `CODE_EXPIRED` | 400 | 验证码已过期 |
| `CODE_ALREADY_USED` | 400 | 验证码已使用 |
| `UNAUTHORIZED` | 401 | 未认证 |
| `INVALID_TOKEN` | 401 | Token无效 |
| `TOKEN_EXPIRED` | 401 | Token已过期 |
| `INVALID_REFRESH_TOKEN` | 401 | Refresh Token无效 |
| `FORBIDDEN` | 403 | 无权限 |
| `ACCOUNT_BLOCKED` | 403 | 账号被锁定 |
| `RESOURCE_NOT_FOUND` | 404 | 资源不存在 |

#### 限流错误（429）

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `RATE_LIMIT_EXCEEDED` | 429 | 请求频率过高 |
| `TOO_MANY_ATTEMPTS` | 429 | 尝试次数过多 |

#### 服务器错误（5xx）

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INTERNAL_SERVER_ERROR` | 500 | 服务器内部错误 |
| `SMS_SEND_FAILED` | 500 | 短信发送失败 |
| `DATABASE_ERROR` | 500 | 数据库错误 |
| `FILE_UPLOAD_FAILED` | 500 | 文件上传失败 |

### 错误处理示例

```python
from fastapi import HTTPException, status

# 自定义异常
class APIException(HTTPException):
    def __init__(self, code: str, message: str, status_code: int = 400):
        super().__init__(
            status_code=status_code,
            detail={
                "code": code,
                "message": message
            }
        )

# 使用示例
if not user:
    raise APIException("RESOURCE_NOT_FOUND", "用户不存在", 404)
```

---

## 开发环境配置

### 1. 安装依赖

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 2. requirements.txt

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
alembic==1.12.1
redis==5.0.1
aliyun-python-sdk-core==2.14.0
aliyun-python-sdk-dysmsapi==2.2.0
python-dotenv==1.0.0
```

### 3. 数据库迁移

```bash
# 初始化迁移
alembic init migrations

# 创建迁移文件
alembic revision --autogenerate -m "Initial migration"

# 执行迁移
alembic upgrade head
```

### 4. 运行开发服务器

```bash
# 开发模式（自动重载）
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 生产模式
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### 5. API文档访问

- **Swagger UI**：http://localhost:8000/docs
- **ReDoc**：http://localhost:8000/redoc

---

## 部署配置

### 1. Docker部署

**Dockerfile**：

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**docker-compose.yml**：

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/tennis_frog
      - REDIS_HOST=redis
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs

  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=tennis_frog
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 2. Nginx配置

```nginx
server {
    listen 80;
    server_name api.tennis.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. 环境变量（生产环境）

```env
DEBUG=False
SECRET_KEY=your-production-secret-key
DATABASE_URL=postgresql://user:password@db-host:5432/tennis_frog
JWT_SECRET_KEY=your-production-jwt-secret
# ... 其他配置
```

---

## 测试指南

### 1. 单元测试

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_send_sms_code():
    response = client.post(
        "/api/v1/auth/send-sms-code",
        json={
            "phone": "15257854295",
            "country_code": "+86",
            "device_info": {
                "device_id": "test-device",
                "device_type": "iOS"
            }
        }
    )
    assert response.status_code == 200
    assert response.json()["success"] == True
```

### 2. 集成测试

```bash
# 运行测试
pytest tests/

# 生成覆盖率报告
pytest --cov=app tests/
```

### 3. API测试工具

- **Postman**：导入API集合进行测试
- **curl**：命令行测试
- **Swagger UI**：浏览器内测试

---

## 安全规范

### 1. 输入验证

- 所有输入参数必须验证
- 使用Pydantic进行数据验证
- 防止SQL注入（使用ORM参数化查询）
- 防止XSS攻击（输出转义）

### 2. 认证安全

- Token存储在HTTP-only Cookie（可选）
- 使用HTTPS传输Token
- Token过期时间合理设置
- 支持Token撤销机制

### 3. 限流保护

- 验证码发送：60秒/次
- 登录尝试：5次/10分钟
- API请求：1000次/小时（认证后）

### 4. 日志记录

- 记录所有认证相关操作
- 记录异常请求
- 记录敏感操作（登录、登出、资料修改）

### 5. 数据加密

- 数据库连接使用SSL
- 敏感数据加密存储
- 密码使用bcrypt加密（如需要）

---

## API端点总结

| 方法 | 路径 | 认证 | 说明 |
|------|------|------|------|
| POST | `/api/v1/auth/send-sms-code` | 否 | 发送短信验证码 |
| POST | `/api/v1/auth/login-with-sms` | 否 | 验证码登录 |
| POST | `/api/v1/auth/refresh-token` | Refresh Token | 刷新Token |
| POST | `/api/v1/auth/logout` | Access Token | 用户登出 |
| GET | `/api/v1/users/me` | Access Token | 获取当前用户信息 |
| PATCH | `/api/v1/users/me` | Access Token | 更新用户资料 |
| POST | `/api/v1/users/me/avatar` | Access Token | 上传头像 |

---

## 总结

### 设计特点

✅ **RESTful风格**：遵循REST API设计规范  
✅ **统一响应格式**：所有接口使用统一结构  
✅ **JWT认证**：安全的Token认证机制  
✅ **完整文档**：自动生成Swagger文档  
✅ **错误处理**：统一的错误码和消息  
✅ **安全规范**：完善的输入验证和安全措施  

### 开发建议

1. **使用FastAPI的自动文档**：Swagger UI和ReDoc
2. **使用Pydantic进行数据验证**：确保数据安全
3. **使用SQLAlchemy ORM**：防止SQL注入
4. **实现限流机制**：防止恶意请求
5. **完善日志记录**：便于问题排查

---

**文档版本**：v1.0  
**最后更新**：2025-11-06  
**维护者**：Tennis-Frog开发团队

