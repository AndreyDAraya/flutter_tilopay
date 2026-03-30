import '../enums.dart';
import 'billing_info.dart';

/// Request body para [POST /admin/processPaymentFAC] — Flujo Nativo.
///
/// El token de tarjeta es generado por el SDK de Tilopay en el cliente.
/// Los datos de tarjeta nunca llegan directamente al servidor del merchant.
class ProcessPaymentFacRequest {
  const ProcessPaymentFacRequest({
    required this.key,
    required this.amount,
    required this.currency,
    required this.billing,
    required this.orderNumber,
    required this.captureMode,
    required this.sessionId,
    required this.redirect,
    required this.cardToken,
    this.amountSinpe,
    this.taxes,
    this.cvv,
    this.cvvEncrypted,
    this.expDate,
    this.cardType,
    this.typeCard,
    this.cardList,
    this.tokenize = false,
    this.tokenexExist,
    this.subscription = false,
    this.method,
    this.lang,
    this.platform,
    this.platformReference,
    this.returnData,
    this.paymentData,
    this.processApplePay = false,
    this.phoneYappy,
  });

  /// Clave de integración/API.
  final String key;

  /// Monto total de la orden.
  final double amount;

  /// Código ISO de moneda (ej. `CRC`, `USD`).
  final String currency;

  /// Información de facturación (firstName, lastName y email son requeridos).
  final BillingInfo billing;

  /// ID de orden del merchant.
  final String orderNumber;

  /// Modo de captura.
  final CaptureMode captureMode;

  /// Identificador único de sesión (máx 25 chars, ej. `APP-{hash}`).
  final String sessionId;

  /// URL de retorno después del pago.
  final String redirect;

  /// Token de tarjeta generado por el SDK de Tilopay.
  final String cardToken;

  /// Monto para método de pago SINPE.
  final double? amountSinpe;

  /// Monto de impuestos (ej. `"0"`).
  final String? taxes;

  /// CVV en texto plano (si no está encriptado).
  final String? cvv;

  /// CVV encriptado desde el SDK/TokenEx.
  final String? cvvEncrypted;

  /// Fecha de expiración de tarjeta — solo dígitos (ej. `"1225"`).
  final String? expDate;

  /// Marca de tarjeta (ej. `"VISA"`).
  final String? cardType;

  /// Tipo/fuente del token.
  final String? typeCard;

  /// Token de tarjeta guardada o `"otra"` para nueva tarjeta.
  final String? cardList;

  /// `true` para guardar la tarjeta para uso futuro.
  final bool tokenize;

  /// Si ya existe un registro en TokenEx.
  final bool? tokenexExist;

  /// `true` si es producto de suscripción.
  final bool subscription;

  /// Método de pago seleccionado (ej. `sinpe`, `yappy`).
  final PaymentMethod? method;

  /// Código de idioma.
  final String? lang;

  /// Plataforma (ej. `flutter-nativo`).
  final String? platform;

  /// JSON con detalles de versión del plugin/plataforma.
  final String? platformReference;

  /// Cadena identificadora del gateway.
  final String? returnData;

  /// Payload de Apple Pay (desde `ApplePaySession`).
  final Map<String, dynamic>? paymentData;

  /// `true` si se está procesando Apple Pay.
  final bool processApplePay;

  /// Datos de teléfono para Yappy.
  final Map<String, dynamic>? phoneYappy;

  Map<String, dynamic> toJson() => {
        'key': key,
        'amount': amount,
        'currency': currency,
        ...billing.toJson(),
        'orderNumber': orderNumber,
        'capture': captureMode.value,
        'sessionId': sessionId,
        'redirect': redirect,
        'card': cardToken,
        'hashVersion': 'V2',
        if (amountSinpe != null) 'amount_sinpe': amountSinpe,
        if (taxes != null) 'taxes': taxes,
        if (cvv != null) 'cvv': cvv,
        if (cvvEncrypted != null) 'cvvEncrypted': cvvEncrypted,
        if (expDate != null) 'expDate': expDate,
        if (cardType != null) 'cardType': cardType,
        if (typeCard != null) 'type_card': typeCard,
        if (cardList != null) 'card_list': cardList,
        if (tokenize) 'tokenize': 'on',
        if (tokenexExist != null) 'tokenex_exist': tokenexExist,
        if (subscription) 'subscription': 1,
        if (method != null) 'method': method!.value,
        if (lang != null) 'lang': lang,
        if (platform != null) 'platform': platform,
        if (platformReference != null) 'platform_reference': platformReference,
        if (returnData != null) 'returnData': returnData,
        if (paymentData != null) 'paymentData': paymentData,
        if (processApplePay) 'processApplePay': true,
        if (phoneYappy != null) 'phoneYappy': phoneYappy,
      };
}
