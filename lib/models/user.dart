import 'package:json_annotation/json_annotation.dart';
import 'token.dart';

part 'user.g.dart';

/// 用户技能等级枚举
enum SkillLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('professional')
  professional,
}

/// 性别枚举
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

/// 打法风格枚举
enum PlayStyle {
  @JsonValue('baseline')
  baseline,
  @JsonValue('serve_and_volley')
  serveAndVolley,
  @JsonValue('all_court')
  allCourt,
}

/// 用户模型（更新为手机号登录模式）
@JsonSerializable()
class User {
  final int id;

  // 手机号（主要登录凭证）
  final String phone;
  @JsonKey(name: 'country_code')
  final String countryCode;

  // 用户名（可选）
  final String? username;

  // 基本信息
  final String? avatar;
  final String? nickname;
  final String? bio;
  final Gender? gender;
  @JsonKey(name: 'birth_date')
  final String? birthDate;

  // 网球相关
  @JsonKey(name: 'skill_level')
  final SkillLevel skillLevel;
  @JsonKey(name: 'play_style')
  final PlayStyle? playStyle;
  @JsonKey(name: 'favorite_court')
  final String? favoriteCourt;
  @JsonKey(name: 'racket_brand')
  final String? racketBrand;

  // 账户状态
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_phone_verified')
  final bool isPhoneVerified;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'is_profile_completed')
  final bool isProfileCompleted;

  // 时间戳
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;

  User({
    required this.id,
    required this.phone,
    this.countryCode = '+86',
    this.username,
    this.avatar,
    this.nickname,
    this.bio,
    this.gender,
    this.birthDate,
    this.skillLevel = SkillLevel.beginner,
    this.playStyle,
    this.favoriteCourt,
    this.racketBrand,
    this.isActive = true,
    this.isPhoneVerified = true,
    this.isPremium = false,
    this.isProfileCompleted = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// 从 JSON 创建
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// 复制并修改部分字段
  User copyWith({
    int? id,
    String? phone,
    String? countryCode,
    String? username,
    String? avatar,
    String? nickname,
    String? bio,
    Gender? gender,
    String? birthDate,
    SkillLevel? skillLevel,
    PlayStyle? playStyle,
    String? favoriteCourt,
    String? racketBrand,
    bool? isActive,
    bool? isPhoneVerified,
    bool? isPremium,
    bool? isProfileCompleted,
    String? createdAt,
    String? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      skillLevel: skillLevel ?? this.skillLevel,
      playStyle: playStyle ?? this.playStyle,
      favoriteCourt: favoriteCourt ?? this.favoriteCourt,
      racketBrand: racketBrand ?? this.racketBrand,
      isActive: isActive ?? this.isActive,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isPremium: isPremium ?? this.isPremium,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// 获取显示名称
  String get displayName => nickname ?? username ?? phone;
}

/// 短信登录响应模型
@JsonSerializable()
class SmsLoginResponse {
  final bool success;
  final String message;
  final SmsLoginData data;

  SmsLoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SmsLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$SmsLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SmsLoginResponseToJson(this);
}

/// 短信登录数据模型
@JsonSerializable()
class SmsLoginData {
  final User user;
  final TokenResponse tokens;

  SmsLoginData({
    required this.user,
    required this.tokens,
  });

  factory SmsLoginData.fromJson(Map<String, dynamic> json) =>
      _$SmsLoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$SmsLoginDataToJson(this);
}
