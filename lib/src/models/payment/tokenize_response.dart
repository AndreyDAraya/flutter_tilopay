/// Modelo que representa la respuesta de Tilopay al completar un flujo de 
/// redireccionamiento (Pago o Tokenización).
class TokenizeResponse {
  const TokenizeResponse({
    required this.code,
    required this.success,
    this.token,
    this.crd,
    this.description,
    this.auth,
    this.orderId,
    this.transactionId,
    this.brand,
    this.lastDigits,
    this.tokenize,
    this.orderHash,
    this.returnData,
  });

  /// Código de respuesta (1 para aprobado).
  final String code;

  /// Indica si la transacción fue exitosa (code == '1').
  final bool success;

  /// Token de la transacción/tarjeta.
  final String? token;

  /// Card Token (CRD). Usado para cobros futuros.
  final String? crd;

  /// Mensaje descriptivo de Tilopay.
  final String? description;

  /// Código de autorización bancaria.
  final String? auth;

  /// ID de orden del comercio.
  final String? orderId;

  /// ID de transacción interna de Tilopay (tpt).
  final String? transactionId;

  /// Marca de la tarjeta (Visa, Mastercard, etc.).
  final String? brand;

  /// Últimos 4 dígitos de la tarjeta.
  final String? lastDigits;

  /// Indica si fue una tokenización ('1' o '0').
  final String? tokenize;

  /// Hash de verificación de la orden.
  final String? orderHash;

  /// Datos adicionales devueltos por el comercio.
  final String? returnData;

  /// Crea una instancia del modelo desde los queryParameters de la URL.
  factory TokenizeResponse.fromQueryParameters(Map<String, String> params) {
    final code = params['code'] ?? '0';
    return TokenizeResponse(
      code: code,
      success: code == '1',
      token: params['token'],
      crd: params['crd'],
      description: params['description'],
      auth: params['auth'],
      orderId: params['order'],
      transactionId: params['tpt'] ?? params['tilopay-transaction'],
      brand: params['brand'],
      lastDigits: params['last-digits'],
      tokenize: params['tokenize'],
      orderHash: params['OrderHash'],
      returnData: params['returnData'],
    );
  }

  @override
  String toString() {
    return 'TokenizeResponse(code: $code, success: $success, crd: $crd, description: $description)';
  }
}
