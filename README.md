# Tennis App - 网球社交平台

Flutter 移动应用前端

## 功能特性

- ✅ 用户注册/登录
- ✅ JWT Token 认证
- ✅ 密码强度检测
- ✅ 忘记密码流程
- 🚧 动态发布与浏览
- 🚧 约球功能
- 🚧 社交互动

## 技术栈

- **框架**: Flutter 3.38.0
- **状态管理**: Riverpod 2.4.9
- **路由**: go_router 13.0.0
- **网络**: Dio 5.4.0
- **本地存储**: shared_preferences 2.2.2

## 快速开始

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 开发模式
flutter run

# 指定设备
flutter run -d chrome  # Web
flutter run -d <device_id>  # 移动设备
```

### 代码生成

```bash
# 生成 JSON 序列化代码
flutter pub run build_runner build --delete-conflicting-outputs
```

### 代码检查

```bash
# 分析代码
flutter analyze

# 格式化代码
dart format lib/

# 自动修复
dart fix --apply
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── config/                # 配置文件
│   ├── api_config.dart   # API 配置
│   └── theme.dart        # 主题配置
├── models/                # 数据模型
│   ├── user.dart
│   └── token.dart
├── providers/             # Riverpod 状态管理
│   └── auth_provider.dart
├── services/              # API 服务
│   ├── api_service.dart
│   └── auth_service.dart
├── screens/               # 页面
│   └── auth/
│       ├── login_screen.dart
│       ├── register_screen.dart
│       └── forgot_password_screen.dart
├── widgets/               # 通用组件
│   └── common/
└── utils/                 # 工具函数
```

## API 配置

编辑 `lib/config/api_config.dart` 修改后端 API 地址：

```dart
static const String baseUrl = 'http://localhost:8000';
```

## 设计文档

- [用户登录系统设计文档](../项目介绍/用户登录系统设计文档.md)
- [技术实践路径](../项目介绍/技术实践路径.md)
- [Figma 设计稿](https://www.figma.com/design/XBUIg5DVwkoLkDFk3FEuRO/Tennis-Frog)

## 开发规范

- 遵循 Flutter 官方代码规范
- 使用 `flutter analyze` 检查代码
- 提交前运行 `dart format lib/`
- Git commit 遵循 Conventional Commits

## License

MIT

