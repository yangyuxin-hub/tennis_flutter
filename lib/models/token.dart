import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

/// Token 响应模型
@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  TokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'bearer',
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

/// 验证码请求模型
@JsonSerializable()
class SendCodeRequest {
  final String? email;
  final String? phone;
  @JsonKey(name: 'code_type')
  final String codeType;

  SendCodeRequest({
    this.email,
    this.phone,
    required this.codeType,
  });

  Map<String, dynamic> toJson() => _$SendCodeRequestToJson(this);
}

/// 邮箱验证请求模型
@JsonSerializable()
class EmailVerificationRequest {
  final String email;
  final String code;

  EmailVerificationRequest({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() => _$EmailVerificationRequestToJson(this);
}

/// 重置密码请求模型
@JsonSerializable()
class ResetPasswordRequest {
  final String email;
  final String code;
  @JsonKey(name: 'new_password')
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

/// 修改密码请求模型
@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'old_password')
  final String oldPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}
