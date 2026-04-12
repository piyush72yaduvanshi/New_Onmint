/// Authentication token model
class AuthToken {
  final String token;
  final DateTime expiresAt;
  final String userId;
  final String role;
  
  const AuthToken({
    required this.token,
    required this.expiresAt,
    required this.userId,
    required this.role,
  });
  
  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// Check if token is valid (not expired)
  bool get isValid => !isExpired;
  
  /// Create AuthToken from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'] ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? 
                 DateTime.now().add(const Duration(days: 7)),
      userId: json['userId'] ?? '',
      role: json['role'] ?? '',
    );
  }
  
  /// Convert AuthToken to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'userId': userId,
      'role': role,
    };
  }

  /// Create token from JWT payload (simplified)
  factory AuthToken.fromJwtPayload(String token, Map<String, dynamic> payload) {
    try {
      print('🎫 Creating AuthToken from JWT...');
      print('🎫 Token: ${token.substring(0, 20)}...');
      print('🎫 Payload: $payload');
      
      final exp = payload['exp'] as int?;
      final expiresAt = exp != null 
          ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          : DateTime.now().add(const Duration(days: 7));
      
      final userId = payload['userId'] as String? ?? 
                     payload['sub'] as String? ?? 
                     payload['id'] as String? ?? 
                     payload['_id'] as String? ?? 
                     '';
      
      final role = payload['role'] as String? ?? 'patient';
      
      print('🎫 Parsed - userId: $userId, role: $role, expires: $expiresAt');
      
      return AuthToken(
        token: token,
        expiresAt: expiresAt,
        userId: userId,
        role: role,
      );
    } catch (e) {
      print('❌ Error creating AuthToken: $e');
      print('❌ Token type: ${token.runtimeType}');
      print('❌ Payload type: ${payload.runtimeType}');
      rethrow;
    }
  }

  /// Copy with method for immutable updates
  AuthToken copyWith({
    String? token,
    DateTime? expiresAt,
    String? userId,
    String? role,
  }) {
    return AuthToken(
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthToken &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          userId == other.userId;

  @override
  int get hashCode => token.hashCode ^ userId.hashCode;

  @override
  String toString() => 'AuthToken(userId: $userId, role: $role, expires: $expiresAt)';
}