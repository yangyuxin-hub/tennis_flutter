import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// 认证状态类
class AuthState {
  final String? token;
  final String? refreshToken;
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.token,
    this.refreshToken,
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  /// 复制并修改部分字段
  AuthState copyWith({
    String? token,
    String? refreshToken,
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 清空状态
  AuthState clear() {
    return AuthState();
  }
}

/// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // 不在构造函数中调用异步操作，改为手动初始化
  }

  /// 初始化：从本地存储恢复 token
  Future<void> init() async {
    // 如果已经初始化过，则跳过
    if (state.isAuthenticated || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (token != null) {
        // 设置 token 到 API 服务
        apiService.setToken(token);

        // 尝试获取用户信息
        try {
          final user = await authService.getCurrentUser();
          state = state.copyWith(
            token: token,
            refreshToken: refreshToken,
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } catch (e) {
          // Token 可能已过期，清除本地存储
          await _clearLocalStorage();
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: '初始化失败: $e',
        isLoading: false,
      );
    }
  }

  /// 发送短信验证码
  Future<void> sendSmsCode({
    required String phone,
    String countryCode = '+86',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await authService.sendSmsCode(
        phone: phone,
        countryCode: countryCode,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 短信验证码登录
  Future<void> loginWithSms({
    required String phone,
    required String code,
    String countryCode = '+86',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 调用短信登录 API
      final loginResponse = await authService.loginWithSms(
        phone: phone,
        code: code,
        countryCode: countryCode,
      );

      final user = loginResponse.data.user;
      final tokens = loginResponse.data.tokens;

      // 设置 token 到 API 服务
      apiService.setToken(tokens.accessToken);

      // 保存到本地存储
      await _saveToLocalStorage(
        tokens.accessToken,
        tokens.refreshToken,
      );

      // 更新状态
      state = state.copyWith(
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      // 调用登出 API
      await authService.logout();
    } catch (e) {
      // 即使 API 调用失败，也要清除本地状态
    } finally {
      // 清除本地存储
      await _clearLocalStorage();

      // 清除 API 服务的 token
      apiService.clearToken();

      // 重置状态
      state = state.clear();
    }
  }

  /// 刷新 Token
  Future<void> refreshAccessToken() async {
    if (state.refreshToken == null) {
      throw Exception('没有刷新令牌');
    }

    try {
      final tokenResponse = await authService.refreshToken(state.refreshToken!);

      // 设置新 token
      apiService.setToken(tokenResponse.accessToken);

      // 保存到本地存储
      await _saveToLocalStorage(
        tokenResponse.accessToken,
        tokenResponse.refreshToken ?? state.refreshToken,
      );

      // 更新状态
      state = state.copyWith(
        token: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken ?? state.refreshToken,
      );
    } catch (e) {
      // Token 刷新失败，需要重新登录
      await logout();
      rethrow;
    }
  }

  /// 更新用户信息
  Future<void> updateUserInfo() async {
    try {
      final user = await authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: '更新用户信息失败: $e');
    }
  }

  /// 保存到本地存储
  Future<void> _saveToLocalStorage(String token, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }

  /// 清除本地存储
  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}

/// 认证状态 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 当前用户 Provider（便捷访问）
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// 是否已认证 Provider（便捷访问）
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
