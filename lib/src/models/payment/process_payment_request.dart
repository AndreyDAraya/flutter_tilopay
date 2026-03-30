import '../enums.dart';
import 'billing_info.dart';

/// Request body para [POST /api/v1/processPayment] — Flujo Redirect.
///
/// La respuesta típica es [type: "100"] con la URL al formulario hospedado
/// de Tilopay. El usuario es redirigido allí para completar el pago.
class ProcessPaymentRequest {
  const ProcessPaymentRequest({
    required this.key,
    required this.amount,
    required this.currency,
    required this.orderNumber,
    required this.captureMode,
    required this.redirect,
    this.billing,
    this.subscription = false,
    this.platform,
    this.platformReference,
    this.lang,
    this.returnData,
  });

  /// Clave de integración/API.
  final String key;

  /// Monto total de la orden.
  final double amount;

  /// Código ISO de moneda (ej. `CRC`, `USD`).
  final String currency;

  /// ID de orden del merchant.
  final String orderNumber;

  /// Modo de captura.
  final CaptureMode captureMode;

  /// URL de retorno después del pago.
  final String redirect;

  /// Información de facturación del cliente (opcional).
  final BillingInfo? billing;

  /// `true` si la orden contiene un producto de suscripción.
  final bool subscription;

  /// Identificador de plataforma (ej. `flutter-redirect`).
  final String? platform;

  /// JSON con detalles de versión del plugin/plataforma.
  final String? platformReference;

  /// Código de idioma (ej. `en-US`, `es-CR`).
  final String? lang;

  /// Cadena identificadora del gateway.
  final String? returnData;

  Map<String, dynamic> toJson() => {
        'key': key,
        'amount': amount,
        'currency': currency,
        'orderNumber': orderNumber,
        'capture': captureMode.value,
        'redirect': redirect,
        'hashVersion': 'V2',
        if (billing != null) ...billing!.toJson(),
        if (subscription) 'subscription': 1,
        if (platform != null) 'platform': platform,
        if (platformReference != null) 'platform_reference': platformReference,
        if (lang != null) 'lang': lang,
        if (returnData != null) 'returnData': returnData,
      };
}
