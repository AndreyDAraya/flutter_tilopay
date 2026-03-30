/// Request body para [POST /api/v1/login] — Flujo Redirect.
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// API User (campo email en la API).
  final String email;

  /// API Password.
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
