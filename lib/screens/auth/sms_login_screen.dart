import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';

/// 验证码登录页面 - Keep风格
class SmsLoginScreen extends ConsumerStatefulWidget {
  final String? initialPhone; // 从上一页传递的手机号

  const SmsLoginScreen({super.key, this.initialPhone});

  @override
  ConsumerState<SmsLoginScreen> createState() => _SmsLoginScreenState();
}

class _SmsLoginScreenState extends ConsumerState<SmsLoginScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    // 设置状态栏为浅色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _phoneNumber = widget.initialPhone ?? '';

    // 自动发送验证码
    if (_phoneNumber.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _sendVerificationCode();
        }
      });
    }

    // 自动聚焦第一个输入框
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _codeFocusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    setState(() => _isLoading = true);

    try {
      // 调用AuthProvider发送验证码
      await ref.read(authProvider.notifier).sendSmsCode(
            phone: _phoneNumber,
            countryCode: '+86',
          );

      if (mounted) {
        _showSnackBar('验证码已发送', const Color(0xFF7B5FFF));
        setState(() {
          _countdown = 60;
          _canResend = false;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _parseErrorMessage(e.toString());
        _showSnackBar(errorMsg, Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  /// 重新发送验证码
  Future<void> _resendVerificationCode() async {
    if (!_canResend || _isLoading) return;
    await _sendVerificationCode();
  }

  /// 验证码输入完成
  void _onCodeComplete() async {
    final code = _codeControllers.map((c) => c.text).join();

    if (code.length != 4) return;

    setState(() => _isLoading = true);

    try {
      // 调用AuthProvider进行登录
      await ref.read(authProvider.notifier).loginWithSms(
            phone: _phoneNumber,
            code: code,
            countryCode: '+86',
          );

      if (mounted) {
        // 登录成功，保存手机号（用于下次一键登录）
        await StorageService.savePhoneNumber(_phoneNumber);

        _showSnackBar('登录成功', const Color(0xFF7B5FFF));
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _parseErrorMessage(e.toString());
        _showSnackBar(errorMsg, Colors.red);
        // 清空输入
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _codeFocusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 解析错误消息，使其更用户友好
  String _parseErrorMessage(String error) {
    // 移除 "Exception: " 前缀
    error = error.replaceFirst('Exception: ', '');

    // 常见错误映射
    if (error.contains('发送验证码失败')) {
      return '验证码发送失败，请稍后重试';
    } else if (error.contains('登录失败')) {
      return '验证码错误或已过期，请重新输入';
    } else if (error.contains('网络')) {
      return '网络连接失败，请检查网络';
    } else if (error.contains('超时')) {
      return '请求超时，请重试';
    } else if (error.contains('Connection')) {
      return '网络连接失败，请检查网络';
    }

    // 默认返回简化的错误消息
    return error.length > 50 ? '操作失败，请重试' : error;
  }

  /// 显示提示信息
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          bottom: 80.h,
          left: 20.w,
          right: 20.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// 格式化手机号显示
  String _formatPhoneNumber(String phone) {
    if (phone.length < 11) return phone;
    return '+86 ${phone.substring(0, 3)} ${phone.substring(3, 7)} ${phone.substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4E8D),
      body: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A4E8D),
                  Color(0xFF6B5B95),
                  Color(0xFF8B7AB8),
                ],
              ),
            ),
          ),

          // 内容
          SafeArea(
            child: Column(
              children: [
                // 顶部返回按钮
                _buildTopBar(),

                SizedBox(height: 60.h),

                // 标题和提示
                _buildTitle(),

                SizedBox(height: 60.h),

                // 验证码输入框
                _buildCodeInputs(),

                SizedBox(height: 40.h),

                // 确定按钮
                _buildConfirmButton(),

                SizedBox(height: 24.h),

                // 重新获取按钮
                _buildResendButton(),

                const Spacer(),
              ],
            ),
          ),

          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF7B5FFF),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '正在处理...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 顶部栏
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 标题区域
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Text(
            '输入验证码',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '已发送 4 位验证码至 ${_formatPhoneNumber(_phoneNumber)}',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 验证码输入框（4个方框）
  Widget _buildCodeInputs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 均匀分布
        children: List.generate(4, (index) {
          return _buildSingleCodeInput(index);
        }),
      ),
    );
  }

  /// 单个验证码输入框（按照截图设计：白色背景块 + 深色数字）
  Widget _buildSingleCodeInput(int index) {
    return Container(
      width: 65.w,
      height: 75.h,
      decoration: BoxDecoration(
        // 纯白色背景（按照截图）
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: TextField(
          controller: _codeControllers[index],
          focusNode: _codeFocusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333), // 深灰色数字（在白色背景上清晰可见）
            height: 1.2,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
            filled: false,
          ),
          cursorColor: const Color(0xFF7B5FFF), // 紫色光标
          cursorWidth: 2.0,
          cursorHeight: 28.h,
          showCursor: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              // 自动跳转到下一个输入框
              if (index < 3) {
                _codeFocusNodes[index + 1].requestFocus();
              } else {
                // 最后一个输入框，自动提交
                _codeFocusNodes[index].unfocus();
                _onCodeComplete();
              }
            } else if (value.isEmpty && index > 0) {
              // 删除时回退到上一个输入框
              _codeFocusNodes[index - 1].requestFocus();
            }
            setState(() {}); // 更新UI状态
          },
        ),
      ),
    );
  }

  /// 确定按钮
  Widget _buildConfirmButton() {
    final code = _codeControllers.map((c) => c.text).join();
    final isComplete = code.length == 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: isComplete && !_isLoading ? _onCodeComplete : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isComplete
                ? const Color(0xFF5FD381)
                : Colors.white.withValues(alpha: 0.15),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
            elevation: 0,
          ),
          child: Text(
            '确定',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 重新获取按钮
  Widget _buildResendButton() {
    return TextButton(
      onPressed: _canResend ? _resendVerificationCode : null,
      child: Text(
        _canResend ? '重新获取' : '重新获取 ($_countdown)',
        style: TextStyle(
          color: _canResend
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.5),
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
