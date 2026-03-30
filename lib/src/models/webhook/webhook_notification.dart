/// Notificación de webhook enviada por Tilopay al servidor del merchant.
///
/// Tilopay hace un [POST] a la URL configurada por el merchant cuando
/// cambia el estado de un pago.
class WebhookNotification {
  const WebhookNotification({
    required this.orderNumber,
    required this.code,
    required this.orderHash,
    required this.tpt,
    this.auth,
  });

  /// ID de orden del merchant.
  final String orderNumber;

  /// Código de resultado:
  /// - `"1"` → aprobado
  /// - `"Pending"` → pendiente
  /// - otro → fallido
  final String code;

  /// Hash HMAC-SHA256 (64 chars) para verificar autenticidad.
  /// Usar [TilopayHashVerifier.verify] para validarlo.
  final String orderHash;

  /// ID interno de la orden en Tilopay.
  final String tpt;

  /// Código de autorización (presente cuando es aprobado).
  final String? auth;

  /// `true` si el pago fue aprobado.
  bool get isApproved => code == '1';

  /// `true` si el pago está pendiente.
  bool get isPending => code == 'Pending';

  factory WebhookNotification.fromJson(Map<String, dynamic> json) =>
      WebhookNotification(
        orderNumber: json['orderNumber']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        orderHash: json['orderHash']?.toString() ?? '',
        tpt: json['tpt']?.toString() ?? '',
        auth: json['auth']?.toString(),
      );
}

/// Parámetros de retorno del flujo redirect.
///
/// Tilopay redirige al usuario a la URL del merchant con estos
/// parámetros como query parameters GET.
class RedirectCallbackParams {
  const RedirectCallbackParams({
    required this.tpt,
    required this.order,
    required this.code,
    required this.orderHash,
    this.auth,
    this.description,
    this.cardToken,
    this.selectedMethod,
    this.cancelled = false,
  });

  /// ID interno de la orden en Tilopay.
  final String tpt;

  /// ID de orden del merchant.
  final String order;

  /// Código de resultado (`"1"` = aprobado).
  final String code;

  /// Hash HMAC-SHA256 para verificación (64 chars).
  final String orderHash;

  /// Código de autorización del banco.
  final String? auth;

  /// Descripción legible del resultado.
  final String? description;

  /// Token de tarjeta (para tokenización de suscripciones).
  final String? cardToken;

  /// Método de pago utilizado.
  final String? selectedMethod;

  /// `true` si el usuario canceló el pago.
  final bool cancelled;

  /// `true` si el pago fue aprobado.
  bool get isApproved => code == '1' && !cancelled;

  factory RedirectCallbackParams.fromQueryParams(Map<String, String> params) =>
      RedirectCallbackParams(
        tpt: params['tpt'] ?? '',
        order: params['order'] ?? '',
        code: params['code'] ?? '',
        orderHash: params['OrderHash'] ?? '',
        auth: params['auth'],
        description: params['description'],
        cardToken: params['crd'],
        selectedMethod: params['selected_method'],
        cancelled: params['wp_cancel'] == 'yes',
      );
}
