import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static const String _keyPhoneNumber = 'saved_phone_number';
  static const String _keyMaskedPhone = 'masked_phone_number';

  /// 保存手机号
  static Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhoneNumber, phoneNumber);

    // 保存脱敏的手机号用于显示
    final masked = _maskPhoneNumber(phoneNumber);
    await prefs.setString(_keyMaskedPhone, masked);
  }

  /// 获取保存的手机号（完整）
  static Future<String?> getSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  /// 获取脱敏的手机号（用于显示）
  static Future<String?> getMaskedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMaskedPhone);
  }

  /// 清除保存的手机号
  static Future<void> clearPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPhoneNumber);
    await prefs.remove(_keyMaskedPhone);
  }

  /// 检查是否有保存的手机号
  static Future<bool> hasPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPhoneNumber);
  }

  /// 脱敏手机号
  static String _maskPhoneNumber(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}
