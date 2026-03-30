/// Configuración del cliente de Tilopay.
class TilopayConfig {
  const TilopayConfig({
    required this.apiKey,
    required this.apiUser,
    required this.apiPassword,
    this.environment = TilopayEnvironment.production,
    this.defaultLocale = 'es-CR',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.debugLog = false,
  });

  /// Clave de integración/API.
  final String apiKey;

  /// Usuario de la API.
  final String apiUser;

  /// Contraseña de la API.
  final String apiPassword;

  /// Entorno: producción o sandbox (prueba).
  final TilopayEnvironment environment;

  /// Locale por defecto para las peticiones (ej. `es-CR`, `en-US`).
  final String defaultLocale;

  /// Timeout de conexión.
  final Duration connectTimeout;

  /// Timeout de recepción de respuesta.
  final Duration receiveTimeout;

  /// Indica si se deben imprimir los logs de las peticiones de red.
  final bool debugLog;

  /// URL base según el entorno.
  String get baseUrl => environment.baseUrl;
}

/// Entorno de ejecución del gateway.
enum TilopayEnvironment {
  /// Entorno de producción.
  production('https://app.tilopay.com'),

  /// Entorno de prueba / sandbox.
  sandbox('https://app.tilopay.com');

  const TilopayEnvironment(this.baseUrl);
  final String baseUrl;
}
