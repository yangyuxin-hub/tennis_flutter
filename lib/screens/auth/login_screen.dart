import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'country_code_picker_screen.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';

/// 登录页面 - 简化版
/// 全屏沉浸式设计，参照Keep/滑呗等主流App
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _agreeToTerms = false; // 是否同意服务条款
  bool _isLoading = false;
  String _countryCode = '+86'; // 当前选择的国家代码
  String? _savedMaskedPhone; // 保存的脱敏手机号
  bool _isReturningUser = false; // 是否是回访用户

  // 手机号输入控制器
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 监听输入框焦点变化
    _phoneFocusNode.addListener(() {
      setState(() {}); // 更新UI以显示聚焦状态
    });

    // 检查是否有保存的手机号
    _checkSavedPhoneNumber();
  }

  /// 检查本地是否保存了手机号（老用户）
  Future<void> _checkSavedPhoneNumber() async {
    final hasPhone = await StorageService.hasPhoneNumber();

    if (hasPhone) {
      final maskedPhone = await StorageService.getMaskedPhoneNumber();
      if (mounted && maskedPhone != null) {
        setState(() {
          _savedMaskedPhone = maskedPhone;
          _isReturningUser = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    // 恢复状态栏
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  /// 验证手机号格式
  bool _isValidPhoneNumber(String phone) {
    if (phone.length != 11) return false;
    final regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(phone);
  }

  /// 验证码登录（新用户 - 首次登录）
  Future<void> _handleSmsLogin() async {
    // 检查是否同意服务条款
    if (!_agreeToTerms) {
      _showSnackBar('请先阅读并同意服务条款和隐私政策', Colors.orange);
      return;
    }

    final phone = _phoneController.text.trim();

    // 验证手机号
    if (!_isValidPhoneNumber(phone)) {
      _showSnackBar('请输入正确的手机号', Colors.orange);
      return;
    }

    // 跳转到手机号验证码登录页面，并传递手机号
    if (mounted) {
      context.push('/login-sms', extra: phone);
    }
  }

  /// 保存手机号到本地（首次登录成功后）
  /// 在登录成功时调用此方法保存用户手机号
  // ignore: unused_element
  Future<void> _savePhoneNumber(String phoneNumber) async {
    // TODO: 保存到SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('saved_phone_number', phoneNumber);
  }

  /// 解析错误消息，使其更用户友好
  String _parseErrorMessage(String error) {
    error = error.replaceFirst('Exception: ', '');

    if (error.contains('发送验证码失败') || error.contains('发送失败')) {
      return '验证码发送失败，请稍后重试';
    } else if (error.contains('未找到保存的手机号')) {
      return '未找到保存的手机号，请重新输入';
    } else if (error.contains('网络')) {
      return '网络连接失败，请检查网络';
    } else if (error.contains('超时')) {
      return '请求超时，请重试';
    } else if (error.contains('Connection')) {
      return '网络连接失败，请检查网络';
    }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(
          bottom: 80.h,
          left: 20.w,
          right: 20.w,
        ),
      ),
    );
  }

  /// 跳过登录（游客模式）
  void _skipLogin() {
    // TODO: 实现游客模式
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4E8D),
      body: Stack(
        children: [
          // 背景图层
          _buildBackground(),

          // 内容层
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部栏
                _buildTopBar(),

                SizedBox(height: 60.h),

                // 标题区域
                _buildTitleSection(),

                SizedBox(height: 60.h),

                // 手机号区域：老用户显示脱敏手机号，新用户显示输入框
                if (_isReturningUser)
                  _buildReturningUserSection()
                else
                  _buildNewUserSection(),

                const Spacer(),

                // 第三方登录
                _buildThirdPartyLogin(),

                SizedBox(height: 24.h),

                // 协议勾选
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: _buildAgreementCheckbox(),
                ),

                SizedBox(height: 32.h),
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

  /// 背景图层 - Keep风格紫色渐变
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A4E8D), // 深紫色
            Color(0xFF6B5B95), // 中紫色
            Color(0xFF8B7AB8), // 淡紫色
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// 顶部栏
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 测试按钮：切换用户类型（仅开发测试用）
          if (!_isReturningUser)
            TextButton(
              onPressed: () async {
                // 模拟保存手机号
                await StorageService.savePhoneNumber('15257854295');
                _checkSavedPhoneNumber();
                _showSnackBar('已切换到老用户模式', Colors.green);
              },
              child: Text(
                '测试老用户',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14.sp,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                // 清除保存的手机号
                await StorageService.clearPhoneNumber();
                setState(() {
                  _savedMaskedPhone = null;
                  _isReturningUser = false;
                });
                _showSnackBar('已切换到新用户模式', Colors.green);
              },
              child: Text(
                '测试新用户',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14.sp,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              // TODO: 跳转到密码登录页面
              _showSnackBar('密码登录功能开发中', Colors.blue);
            },
            child: Text(
              '密码登录',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 标题区域
  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isReturningUser ? '其他手机号登录' : '手机号登录/注册',
                style: TextStyle(
                  fontSize: _isReturningUser ? 18.sp : 32.sp,
                  fontWeight:
                      _isReturningUser ? FontWeight.w500 : FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
          if (!_isReturningUser) ...[
            SizedBox(height: 12.h),
            Text(
              '快速找到好友，一站式记录你的运动',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 老用户区域（显示脱敏手机号）
  Widget _buildReturningUserSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          // 显示脱敏手机号
          Text(
            _savedMaskedPhone ?? '',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '中国移动提供认证服务',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 60.h),

          // 一键登录按钮
          _buildOneClickLoginButton(),

          SizedBox(height: 20.h),

          // 随便逛逛
          TextButton(
            onPressed: _skipLogin,
            child: Text(
              '随便逛逛',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 新用户区域（显示手机号输入框）
  Widget _buildNewUserSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          // 国家代码 + 手机号输入
          _buildPhoneInputWithCountryCode(),

          SizedBox(height: 32.h),

          // 下一步按钮
          _buildNextButton(),

          SizedBox(height: 24.h),

          // 随便逛逛 | 找回账号
          _buildBottomLinks(),
        ],
      ),
    );
  }

  /// 国家代码 + 手机号输入框 (Keep风格 - 优化半透明效果，无边框)
  Widget _buildPhoneInputWithCountryCode() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08), // 更低的不透明度，几乎透明
        borderRadius: BorderRadius.circular(28.r),
        // 去掉边框
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Row(
        children: [
          // 国家代码选择器
          InkWell(
            onTap: () async {
              // 打开国家代码选择器
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (context) => CountryCodePickerScreen(
                    currentCode: _countryCode,
                  ),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  _countryCode = result;
                });
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    _countryCode,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: 1,
            height: 24.h,
            color: Colors.white.withValues(alpha: 0.2),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
          ),

          // 手机号输入框
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              style: TextStyle(
                fontSize: 18.sp, // 增大字号，更容易看清
                color: Colors.white, // 纯白色
                fontWeight: FontWeight.w500, // 加粗，更清晰
                letterSpacing: 1.0, // 增加字符间距
                height: 1.2,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '输入手机号码',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                filled: false, // 确保不填充背景
                fillColor: Colors.transparent, // 透明背景
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterText: '', // 隐藏字符计数
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.h, horizontal: 0),
                isDense: true,
              ),
              cursorColor: Colors.white, // 光标颜色设为白色
              cursorWidth: 2.0, // 光标宽度
              cursorHeight: 20.h, // 光标高度
              showCursor: true, // 确保显示光标
              onChanged: (value) {
                setState(() {}); // 更新按钮状态
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 一键登录按钮（老用户）
  Widget _buildOneClickLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _agreeToTerms && !_isLoading ? _handleOneClickLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _agreeToTerms
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
        child: _isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '一键登录/注册',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// 一键登录处理（自动发送验证码）
  Future<void> _handleOneClickLogin() async {
    setState(() => _isLoading = true);

    try {
      // 获取完整手机号（从本地存储）
      final fullPhone = await StorageService.getSavedPhoneNumber();

      if (fullPhone == null || fullPhone.isEmpty) {
        throw Exception('未找到保存的手机号');
      }

      // 自动发送验证码并跳转到验证码输入页
      await ref.read(authProvider.notifier).sendSmsCode(
            phone: fullPhone,
            countryCode: _countryCode,
          );

      if (mounted) {
        _showSnackBar('验证码已发送', const Color(0xFF7B5FFF));
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          // 跳转到验证码输入页
          context.push('/login-sms', extra: fullPhone);
        }
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

  /// 下一步按钮 (Keep风格 - 优化半透明效果)
  Widget _buildNextButton() {
    final canSubmit = _agreeToTerms &&
        !_isLoading &&
        _isValidPhoneNumber(_phoneController.text.trim());

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: canSubmit ? _handleSmsLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit
              ? const Color(0xFF5FD381) // Keep绿色
              : Colors.white.withValues(alpha: 0.15), // 降低禁用状态不透明度
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.5), // 禁用时文字也变淡
        ),
        child: _isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '下一步',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// 底部链接 (随便逛逛 | 找回账号)
  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _skipLogin,
          child: Text(
            '随便逛逛',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15.sp,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 14.h,
          color: Colors.white.withValues(alpha: 0.5),
          margin: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        TextButton(
          onPressed: () {
            // TODO: 找回账号功能
            _showSnackBar('找回账号功能开发中', Colors.blue);
          },
          child: Text(
            '找回账号',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }

  /// 协议勾选 (Keep风格)
  Widget _buildAgreementCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 18.w,
          height: 18.w,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            shape: const CircleBorder(),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.transparent;
            }),
            checkColor: const Color(0xFF4A4E8D),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
              children: [
                const TextSpan(text: '我已阅读并同意 Keep '),
                TextSpan(
                  text: '用户协议',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' 和 '),
                TextSpan(
                  text: '隐私政策',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 第三方登录 (Keep风格 - 圆形图标)
  Widget _buildThirdPartyLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildThirdPartyButton(
          icon: Icons.phone_android, // 华为图标（用手机代替）
          onTap: () => _showSnackBar('华为登录功能开发中', Colors.blue),
        ),
        SizedBox(width: 32.w),
        _buildThirdPartyButton(
          icon: Icons.wechat,
          onTap: () => _showSnackBar('微信登录功能开发中', Colors.blue),
        ),
        SizedBox(width: 32.w),
        _buildThirdPartyButton(
          icon: Icons.messenger_outline, // QQ图标（用消息代替）
          onTap: () => _showSnackBar('QQ登录功能开发中', Colors.blue),
        ),
        SizedBox(width: 32.w),
        _buildThirdPartyButton(
          icon: Icons.more_horiz,
          onTap: () => _showSnackBar('更多登录方式开发中', Colors.blue),
        ),
      ],
    );
  }

  /// 第三方登录按钮 (Keep风格 - 简洁圆形)
  Widget _buildThirdPartyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.w,
          color: Colors.white,
        ),
      ),
    );
  }
}
