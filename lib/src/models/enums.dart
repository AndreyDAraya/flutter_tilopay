/// Tipo de modificación de pago.
enum ModificationType {
  /// Capturar un pago previamente autorizado.
  capture(1),

  /// Reembolsar un pago capturado.
  refund(2),

  /// Reversar un pago autorizado.
  reversal(3);

  const ModificationType(this.value);
  final int value;
}

/// Tipo de respuesta del gateway de Tilopay.
enum TilopayResponseType {
  /// Redirigir al formulario de pago hospedado (flujo redirect)
  /// o mostrar el challenge 3DS (flujo nativo).
  redirect('100'),

  /// Pago aprobado.
  approved('200'),

  /// Error de licencia.
  licenseError('300'),

  /// Requiere procesamiento adicional via TokenEx (flujo nativo).
  /// Se detecta cuando `type == "400"` y `card.brand == "TOKENEX"`.
  tokenexRequired('400'),

  /// Error de integración — API Key no encontrada o parámetros inválidos.
  /// Se detecta cuando `type == "400"` sin indicador TokenEx.
  integrationError('400'),

  /// Desconocido.
  unknown('');

  const TilopayResponseType(this.value);
  final String value;

  /// Convierte el string de tipo a [TilopayResponseType].
  ///
  /// Para distinguir entre [tokenexRequired] e [integrationError] cuando
  /// el valor es `"400"`, usar [PaymentResponse.fromJson] que analiza el
  /// body completo de la respuesta.
  static TilopayResponseType fromString(String? value) {
    switch (value) {
      case '100':
        return TilopayResponseType.redirect;
      case '200':
        return TilopayResponseType.approved;
      case '300':
        return TilopayResponseType.licenseError;
      case '400':
        return TilopayResponseType.integrationError;
      default:
        return TilopayResponseType.unknown;
    }
  }
}

/// Capture mode para un pago.
enum CaptureMode {
  /// Autorizar y capturar inmediatamente.
  captureNow(1),

  /// Solo autorizar (capturar luego con processModification).
  authorizeOnly(0);

  const CaptureMode(this.value);
  final int value;
}

/// Método de pago seleccionado.
enum PaymentMethod {
  card('card'),
  sinpe('sinpe'),
  yappy('yappy'),
  applePay('apple_pay');

  const PaymentMethod(this.value);
  final String value;
}
