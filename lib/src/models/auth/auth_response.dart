/// Respuesta de los endpoints de autenticación.
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    this.expiresIn,
  });

  /// Bearer token para usar en los siguientes requests.
  final String accessToken;

  /// Fecha/hora de expiración (solo presente en loginSdk).
  final String? expiresIn;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['access_token'] as String,
        expiresIn: json['expires_in']?.toString(),
      );
}
