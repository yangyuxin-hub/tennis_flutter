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

  // ==================== 认证相关 API ====================
  /// 认证相关 API 端点
  static const AuthEndpoints auth = AuthEndpoints._();

  // ==================== 用户相关 API ====================
  /// 用户相关 API 端点
  static const UserEndpoints user = UserEndpoints._();

  // ==================== 帖子相关 API ====================
  /// 帖子相关 API 端点
  static const PostEndpoints post = PostEndpoints._();

  // ==================== 比赛相关 API ====================
  /// 比赛相关 API 端点
  static const MatchEndpoints match = MatchEndpoints._();

  // ==================== 消息相关 API ====================
  /// 消息相关 API 端点
  static const MessageEndpoints message = MessageEndpoints._();

  // ==================== 通知相关 API ====================
  /// 通知相关 API 端点
  static const NotificationEndpoints notification = NotificationEndpoints._();
}

/// 认证相关 API 端点
class AuthEndpoints {
  const AuthEndpoints._();

  // 手机号验证码登录
  final String sendSmsCode = '/api/v1/auth/send-sms-code';
  final String loginWithSms = '/api/v1/auth/login-with-sms';
  final String refreshToken = '/api/v1/auth/refresh-token';
  final String logout = '/api/v1/auth/logout';

  // 第三方登录
  final String loginWithWechat = '/api/v1/auth/login/wechat';
  final String loginWithQQ = '/api/v1/auth/login/qq';
  final String loginWithApple = '/api/v1/auth/login/apple';
}

/// 用户相关 API 端点
class UserEndpoints {
  const UserEndpoints._();

  final String me = '/api/v1/users/me';
  final String updateProfile = '/api/v1/users/me';
  final String uploadAvatar = '/api/v1/users/me/avatar';
  final String list = '/api/v1/users';
  final String detail = '/api/v1/users/{id}';
  final String follow = '/api/v1/users/{id}/follow';
  final String unfollow = '/api/v1/users/{id}/unfollow';
  final String followers = '/api/v1/users/{id}/followers';
  final String following = '/api/v1/users/{id}/following';
}

/// 帖子相关 API 端点
class PostEndpoints {
  const PostEndpoints._();

  final String list = '/api/v1/posts';
  final String detail = '/api/v1/posts/{id}';
  final String create = '/api/v1/posts';
  final String update = '/api/v1/posts/{id}';
  final String delete = '/api/v1/posts/{id}';
  final String like = '/api/v1/posts/{id}/like';
  final String unlike = '/api/v1/posts/{id}/unlike';
  final String comments = '/api/v1/posts/{id}/comments';
  final String addComment = '/api/v1/posts/{id}/comments';
}

/// 比赛相关 API 端点
class MatchEndpoints {
  const MatchEndpoints._();

  final String list = '/api/v1/matches';
  final String detail = '/api/v1/matches/{id}';
  final String create = '/api/v1/matches';
  final String update = '/api/v1/matches/{id}';
  final String delete = '/api/v1/matches/{id}';
  final String join = '/api/v1/matches/{id}/join';
  final String leave = '/api/v1/matches/{id}/leave';
  final String participants = '/api/v1/matches/{id}/participants';
}

/// 消息相关 API 端点
class MessageEndpoints {
  const MessageEndpoints._();

  final String conversations = '/api/v1/messages/conversations';
  final String conversationDetail = '/api/v1/messages/conversations/{id}';
  final String send = '/api/v1/messages/conversations/{id}/messages';
  final String markRead = '/api/v1/messages/{id}/read';
}

/// 通知相关 API 端点
class NotificationEndpoints {
  const NotificationEndpoints._();

  final String list = '/api/v1/notifications';
  final String unreadCount = '/api/v1/notifications/unread-count';
  final String markRead = '/api/v1/notifications/{id}/read';
  final String markAllRead = '/api/v1/notifications/read-all';
}
