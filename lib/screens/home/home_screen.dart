import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

/// 首页（临时简单版本）
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('网球社交平台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_tennis,
              size: 100,
              color: Color(0xFF274125),
            ),
            const SizedBox(height: 24),
            Text(
              '欢迎, ${user?.displayName ?? '用户'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '手机号: ${user?.countryCode ?? '+86'} ${user?.phone ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (user?.username != null)
              Text(
                '用户名: ${user?.username}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '技能等级: ${user?.skillLevel.name ?? 'beginner'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '资料完整度: ${user?.isProfileCompleted == true ? '已完成' : '未完成'}',
              style: TextStyle(
                fontSize: 16,
                color: user?.isProfileCompleted == true
                    ? Colors.green[600]
                    : Colors.orange[600],
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.all(24),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '登录系统已完成！',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '您已成功登录到网球社交平台',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
