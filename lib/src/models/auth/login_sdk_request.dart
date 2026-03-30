/// Request body para [POST /api/v1/loginSdk] — Flujo Nativo.
class LoginSdkRequest {
  const LoginSdkRequest({
    required this.apiUser,
    required this.password,
    required this.key,
  });

  /// API User.
  final String apiUser;

  /// API Password.
  final String password;

  /// API Key / clave de integración.
  final String key;

  Map<String, dynamic> toJson() => {
        'apiuser': apiUser,
        'password': password,
        'key': key,
      };
}
