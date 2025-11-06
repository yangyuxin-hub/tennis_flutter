/// 扩展方法工具类
library;

extension StringExtension on String {
  /// 判断字符串是否为空或null
  bool get isNullOrEmpty => isEmpty;

  /// 判断字符串是否不为空
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 首字母大写
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeExtension on DateTime {
  /// 格式化为 yyyy-MM-dd
  String toDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// 格式化为 yyyy-MM-dd HH:mm:ss
  String toDateTimeString() {
    return '${toDateString()} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }
}
