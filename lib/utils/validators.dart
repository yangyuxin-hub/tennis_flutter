/// 表单验证工具类（手机号登录模式）
class Validators {
  /// 验证是否为空
  static String? required(String? value, [String fieldName = '此字段']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 验证用户名（可选字段）
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 用户名是可选的
    }

    if (value.length < 3) {
      return '用户名至少3个字符';
    }

    if (value.length > 50) {
      return '用户名最多50个字符';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$');
    if (!usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字、下划线和中文';
    }

    return null;
  }

  /// 验证昵称（可选字段）
  static String? nickname(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 昵称是可选的
    }

    if (value.length > 30) {
      return '昵称最多30个字符';
    }

    return null;
  }

  /// 验证手机号（根据国家代码）
  static String? phone(String? value, {String countryCode = '+86'}) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }

    // 去除空格和特殊字符
    value = value.replaceAll(RegExp(r'[\s-]'), '');

    // 根据国家代码进行不同的验证
    switch (countryCode) {
      case '+86': // 中国大陆
        if (value.length != 11) {
          return '请输入11位手机号';
        }
        if (!value.startsWith(RegExp(r'1[3-9]'))) {
          return '请输入有效的手机号';
        }
        break;
      case '+852': // 香港
        if (value.length != 8) {
          return '请输入8位手机号';
        }
        break;
      case '+1': // 美国/加拿大
        if (value.length != 10) {
          return '请输入10位手机号';
        }
        break;
      default:
        // 其他国家基础验证
        if (value.length < 8 || value.length > 15) {
          return '请输入有效的手机号';
        }
    }

    // 只能包含数字
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '手机号只能包含数字';
    }

    return null;
  }

  /// 验证短信验证码（4位）
  static String? smsCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }

    if (value.length != 4) {
      return '验证码为4位数字';
    }

    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return '验证码只能包含数字';
    }

    return null;
  }

  /// 验证验证码（6位 - 邮箱验证码）
  static String? verificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }

    if (value.length != 6) {
      return '验证码为6位数字';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '验证码只能包含数字';
    }

    return null;
  }

  /// 检查手机号格式是否有效（不返回错误消息）
  static bool isValidPhone(String phone, {String countryCode = '+86'}) {
    return Validators.phone(phone, countryCode: countryCode) == null;
  }

  /// 检查验证码格式是否有效
  static bool isValidSmsCode(String code) {
    return Validators.smsCode(code) == null;
  }
}
