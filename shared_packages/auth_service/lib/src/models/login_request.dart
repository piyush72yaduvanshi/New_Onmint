/// Login request model
class LoginRequest {
  final String email;
  final String password;
  
  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Create from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  /// Validate login request
  List<String> validate() {
    final errors = <String>[];

    if (email.isEmpty || !_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty) {
      errors.add('Password is required');
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginRequest(email: $email)';
}