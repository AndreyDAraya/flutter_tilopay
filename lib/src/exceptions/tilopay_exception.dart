/// Excepción base para errores del SDK de Tilopay.
class TilopayException implements Exception {
  const TilopayException(this.message, {this.code, this.rawResponse});

  /// Descripción del error.
  final String message;

  /// Código de error de Tilopay (ej. `"300"`, `"400"`).
  final String? code;

  /// JSON raw de la respuesta de error (para debugging).
  final Map<String, dynamic>? rawResponse;

  @override
  String toString() => 'TilopayException($code): $message';
}

/// Error de autenticación — credenciales inválidas o token expirado.
class TilopayAuthException extends TilopayException {
  const TilopayAuthException(super.message, {super.code, super.rawResponse});

  @override
  String toString() => 'TilopayAuthException($code): $message';
}

/// Error de licencia — plan inactivo o límite de transacciones alcanzado.
class TilopayLicenseException extends TilopayException {
  const TilopayLicenseException(super.message, {super.code, super.rawResponse});

  @override
  String toString() => 'TilopayLicenseException($code): $message';
}

/// Error de integración — API Key no encontrada o parámetros inválidos.
class TilopayIntegrationException extends TilopayException {
  const TilopayIntegrationException(super.message,
      {super.code, super.rawResponse});

  @override
  String toString() => 'TilopayIntegrationException($code): $message';
}

/// Error de red — timeout, sin conexión, o error HTTP.
class TilopayNetworkException extends TilopayException {
  const TilopayNetworkException(super.message, {this.statusCode, super.rawResponse})
      : super(code: null);

  final int? statusCode;

  @override
  String toString() => 'TilopayNetworkException(HTTP $statusCode): $message';
}

/// Error de verificación de hash — la notificación no proviene de Tilopay.
class TilopayHashVerificationException extends TilopayException {
  const TilopayHashVerificationException()
      : super('Hash HMAC-SHA256 inválido — la notificación no es auténtica.');

  @override
  String toString() => 'TilopayHashVerificationException: $message';
}
