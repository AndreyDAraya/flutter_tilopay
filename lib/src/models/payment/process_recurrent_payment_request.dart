import '../enums.dart';

/// Request body para [POST /api/v1/processRecurrentPayment].
///
/// Usado para cobros de suscripciones usando un token de tarjeta
/// guardado de un pago anterior.
class ProcessRecurrentPaymentRequest {
  const ProcessRecurrentPaymentRequest({
    required this.key,
    required this.amount,
    required this.currency,
    required this.email,
    required this.orderNumber,
    required this.captureMode,
    required this.savedCardToken,
    this.redirect,
    this.callFrom,
    this.language,
  });

  /// Clave de integración/API.
  final String key;

  /// Monto de renovación de la suscripción.
  final double amount;

  /// Código ISO de moneda.
  final String currency;

  /// Email del cliente.
  final String email;

  /// ID de orden del merchant.
  final String orderNumber;

  /// Modo de captura.
  final CaptureMode captureMode;

  /// Token de tarjeta guardada del pago previo (campo `crd` del redirect
  /// o `card` de la respuesta del flujo nativo).
  final String savedCardToken;

  /// URL de retorno.
  final String? redirect;

  /// Identificador del caller (ej. `"Flutter Plugin"`).
  final String? callFrom;

  /// Código de idioma.
  final String? language;

  Map<String, dynamic> toJson() => {
        'key': key,
        'amount': amount,
        'currency': currency,
        'email': email,
        'orderNumber': orderNumber,
        'capture': captureMode.value,
        'card': savedCardToken,
        'hashVersion': 'V2',
        if (redirect != null) 'redirect': redirect,
        if (callFrom != null) 'callFrom': callFrom,
        if (language != null) 'language': language,
      };
}
