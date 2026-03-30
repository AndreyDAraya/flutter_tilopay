import '../enums.dart';

/// Request body para [POST /api/v1/processModification].
///
/// Permite capturar, reembolsar o reversar un pago previamente autorizado.
///
/// **Nota importante:** La captura debe realizarse dentro de los 7 días
/// calendario posteriores a la autorización. Después de ese plazo,
/// el pago autorizado se cancela automáticamente.
class ProcessModificationRequest {
  const ProcessModificationRequest({
    required this.orderNumber,
    required this.key,
    required this.amount,
    required this.type,
    this.platform,
    this.platformReference,
  });

  /// ID de orden original del merchant.
  final String orderNumber;

  /// Clave de integración/API.
  final String key;

  /// Monto a capturar/reembolsar/reversar. Se soporta captura parcial.
  final double amount;

  /// Tipo de modificación: captura, reembolso o reverso.
  final ModificationType type;

  /// Plataforma (ej. `flutter-nativo`, `flutter-redirect`).
  final String? platform;

  /// JSON con metadatos de versión de la plataforma.
  final String? platformReference;

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'key': key,
        'amount': amount,
        'type': type.value,
        'hashVersion': 'V2',
        if (platform != null) 'platform': platform,
        if (platformReference != null) 'platform_reference': platformReference,
      };
}
