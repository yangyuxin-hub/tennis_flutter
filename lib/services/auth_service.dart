import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/token.dart';
import 'api_service.dart';

/// 认证服务类
class AuthService {
  final ApiService _apiService = apiService;

  /// 发送短信验证码
  ///
  /// [phone] 手机号
  /// [countryCode] 国家代码，默认+86
  Future<void> sendSmsCode({
    required String phone,
    String countryCode = '+86',
  }) async {
    try {
      await _apiService.post(
        ApiConfig.authSendSmsCode,
        data: {
          'phone': phone,
          'country_code': countryCode,
          'device_info': {
            'device_type': 'mobile',
            'device_name': 'Flutter App',
          },
        },
      );
    } catch (e) {
      throw Exception('发送验证码失败: $e');
    }
  }

  /// 手机号验证码登录
  ///
  /// [phone] 手机号
  /// [code] 验证码
  /// [countryCode] 国家代码，默认+86
  /// 返回登录响应（包含Token和用户信息）
  Future<SmsLoginResponse> loginWithSms({
    required String phone,
    required String code,
    String countryCode = '+86',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.authLoginWithSms,
        data: {
          'phone': phone,
          'code': code,
          'country_code': countryCode,
          'device_info': {
            'device_type': 'mobile',
            'device_name': 'Flutter App',
          },
        },
      );

      return SmsLoginResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('登录失败: $e');
    }
  }

  /// 刷新 Token
  ///
  /// [refreshToken] 刷新令牌
  /// 返回新的 Token
  Future<TokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.post(
        ApiConfig.authRefreshToken,
        data: {'refresh_token': refreshToken},
      );

      return TokenResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('刷新 Token 失败: $e');
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.authLogout);
      _apiService.clearToken();
    } catch (e) {
      throw Exception('登出失败: $e');
    }
  }

  /// 获取当前用户信息
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.authMe);
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 更新用户资料
  ///
  /// [data] 要更新的用户数据
  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        ApiConfig.usersUpdateProfile,
        data: data,
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('更新资料失败: $e');
    }
  }

  /// 上传头像
  ///
  /// [filePath] 头像文件路径
  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.post(
        ApiConfig.usersUploadAvatar,
        data: formData,
      );

      return response.data['avatar_url'] as String;
    } catch (e) {
      throw Exception('上传头像失败: $e');
    }
  }
}

/// 全局单例
final authService = AuthService();
