import '../enums.dart';

/// Respuesta de los endpoints de procesamiento de pago.
///
/// El campo [type] determina el flujo a seguir:
/// - [TilopayResponseType.redirect] → redirigir al usuario a [redirectUrl]
/// - [TilopayResponseType.approved] → pago aprobado
/// - [TilopayResponseType.tokenexRequired] → llamar a processPaymentTokenex
///   (solo en flujo nativo, cuando `card.brand == "TOKENEX"`)
class PaymentResponse {
  const PaymentResponse({
    required this.type,
    this.redirectUrl,
    this.htmlFormData,
    this.response,
    this.auth,
    this.description,
    this.orderId,
    this.rawJson,
  });

  /// Tipo de respuesta del gateway.
  final TilopayResponseType type;

  /// URL de redirección (presente en type `100` y `200`).
  final String? redirectUrl;

  /// HTML del challenge 3DS (presente en type `100` del flujo nativo).
  final String? htmlFormData;

  /// Código de respuesta interno (ej. `"1"` = aprobado).
  final String? response;

  /// Código de autorización del banco.
  final String? auth;

  /// Descripción legible del resultado.
  final String? description;

  /// ID interno de la orden en Tilopay.
  final String? orderId;

  /// JSON raw de la respuesta (útil para logging y debugging).
  final Map<String, dynamic>? rawJson;

  /// `true` si el pago fue aprobado.
  bool get isApproved => type == TilopayResponseType.approved;

  /// `true` si se debe redirigir al formulario hospedado de Tilopay.
  bool get needsRedirect =>
      type == TilopayResponseType.redirect && redirectUrl != null;

  /// `true` si se requiere mostrar el challenge 3DS.
  bool get needs3dsChallenge =>
      htmlFormData != null && htmlFormData!.isNotEmpty;

  /// `true` si se requiere procesamiento TokenEx adicional.
  bool get needsTokenex => type == TilopayResponseType.tokenexRequired;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString();
    final responseType = TilopayResponseType.fromString(typeStr);

    // En el flujo nativo, type 400 con card.brand == TOKENEX indica reintento TokenEx.
    // Sin ese indicador, es un error de integración genérico.
    final isTokenex =
        responseType == TilopayResponseType.integrationError &&
        (json['card'] as Map<String, dynamic>?)?['brand'] == 'TOKENEX';

    return PaymentResponse(
      type: isTokenex ? TilopayResponseType.tokenexRequired : responseType,
      redirectUrl: json['url'] as String?,
      htmlFormData: json['htmlFormData'] as String?,
      response: json['response']?.toString(),
      auth: json['auth']?.toString(),
      description: json['description'] as String?,
      orderId: json['order_id']?.toString(),
      rawJson: json,
    );
  }
}
