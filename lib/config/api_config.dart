import 'package:flutter/foundation.dart';

/// API 配置类
class ApiConfig {
  // 根据编译模式自动切换环境
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kDebugMode
        ? 'http://localhost:8000' // 开发环境
        : 'https://api.tennis.yourdomain.com', // 生产环境
  );

  static const int timeout = 10000; // 超时时间（毫秒）

  // 认证相关 API 端点
  // 手机号验证码登录
  static const String authSendSmsCode = '/api/v1/auth/send-sms-code';
  static const String authLoginWithSms = '/api/v1/auth/login-with-sms';
  static const String authRefreshToken = '/api/v1/auth/refresh-token';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authMe = '/api/v1/users/me';

  // 用户管理
  static const String usersUpdateProfile = '/api/v1/users/me';
  static const String usersUploadAvatar = '/api/v1/users/me/avatar';

  // 第三方登录（V2扩展）
  static const String authLoginWithWechat = '/api/v1/auth/login/wechat';
  static const String authLoginWithQQ = '/api/v1/auth/login/qq';
  static const String authLoginWithApple = '/api/v1/auth/login/apple';

  static const String posts = '/api/posts/';
  static const String matches = '/api/matches/';
  static const String users = '/api/users/';
}
