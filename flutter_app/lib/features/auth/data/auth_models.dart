/// Mirrors backend `app/modules/auth/schemas.py::TokenPairResponse`.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

/// Mirrors backend `app/modules/auth/schemas.py::UserResponse`.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.accountStatus,
  });

  final String id;
  final String email;
  final String? displayName;
  final String accountStatus;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      accountStatus: json['account_status'] as String,
    );
  }
}
