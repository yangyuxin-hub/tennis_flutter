import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/sms_login_screen.dart';
import '../screens/auth/country_code_picker_screen.dart';
import '../screens/home/home_screen.dart';

/// 路由配置 Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/login-sms' ||
          state.matchedLocation == '/country-code-picker';

      // 如果未登录且不在认证页面，跳转到登录页
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 如果已登录且在登录页面，跳转到首页
      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/home';
      }

      return null; // 不需要重定向
    },
    routes: [
      // 登录页面
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 手机号验证码登录页面
      GoRoute(
        path: '/login-sms',
        builder: (context, state) {
          final phone = state.extra as String?;
          return SmsLoginScreen(initialPhone: phone);
        },
      ),

      // 国家代码选择页面
      GoRoute(
        path: '/country-code-picker',
        builder: (context, state) {
          final currentCode = state.extra as String? ?? '+86';
          return CountryCodePickerScreen(currentCode: currentCode);
        },
      ),

      // 首页
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面不存在',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('返回登录'),
            ),
          ],
        ),
      ),
    ),
  );
});
