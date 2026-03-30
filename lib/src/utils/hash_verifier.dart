import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../exceptions/tilopay_exception.dart';
import '../models/webhook/webhook_notification.dart';

/// Utilidad para verificar la autenticidad de notificaciones de Tilopay
/// usando HMAC-SHA256.
///
/// Tanto el webhook como los parámetros de retorno del flujo redirect
/// incluyen un hash que debe validarse antes de procesar el pago.
///
/// ## Algoritmo
/// ```
/// hashKey = tpt + "|" + apiKey + "|" + apiPassword
/// params  = "api_Key=...&api_user=...&orderId=...&..." (query string ordenado)
/// hash    = HMAC-SHA256(params, hashKey)
/// ```
class TilopayHashVerifier {
  const TilopayHashVerifier({
    required this.apiKey,
    required this.apiUser,
    required this.apiPassword,
  });

  final String apiKey;
  final String apiUser;
  final String apiPassword;

  /// Verifica el hash de una notificación de webhook.
  ///
  /// Lanza [TilopayHashVerificationException] si el hash no es válido.
  void verifyWebhook({
    required WebhookNotification notification,
    required double amount,
    required String currency,
    required String email,
  }) {
    _verify(
      tpt: notification.tpt,
      externalOrderId: notification.orderNumber,
      amount: amount,
      currency: currency,
      responseCode: notification.code,
      auth: notification.auth ?? '',
      email: email,
      receivedHash: notification.orderHash,
    );
  }

  /// Verifica el hash de los parámetros de retorno del flujo redirect.
  ///
  /// Lanza [TilopayHashVerificationException] si el hash no es válido.
  void verifyRedirectCallback({
    required RedirectCallbackParams params,
    required double amount,
    required String currency,
    required String email,
  }) {
    _verify(
      tpt: params.tpt,
      externalOrderId: params.order,
      amount: amount,
      currency: currency,
      responseCode: params.code,
      auth: params.auth ?? '',
      email: email,
      receivedHash: params.orderHash,
    );
  }

  /// Calcula el hash HMAC-SHA256 para los parámetros dados.
  ///
  /// Útil para debugging o para implementar verificación personalizada.
  String computeHash({
    required String tpt,
    required String externalOrderId,
    required double amount,
    required String currency,
    required String responseCode,
    required String auth,
    required String email,
  }) {
    final hashKey = '$tpt|$apiKey|$apiPassword';
    final params = _buildQueryString(
      tpt: tpt,
      externalOrderId: externalOrderId,
      amount: amount,
      currency: currency,
      responseCode: responseCode,
      auth: auth,
      email: email,
    );
    final hmac = Hmac(sha256, utf8.encode(hashKey));
    final digest = hmac.convert(utf8.encode(params));
    return digest.toString();
  }

  void _verify({
    required String tpt,
    required String externalOrderId,
    required double amount,
    required String currency,
    required String responseCode,
    required String auth,
    required String email,
    required String receivedHash,
  }) {
    if (receivedHash.length != 64) {
      throw const TilopayHashVerificationException();
    }

    final computed = computeHash(
      tpt: tpt,
      externalOrderId: externalOrderId,
      amount: amount,
      currency: currency,
      responseCode: responseCode,
      auth: auth,
      email: email,
    );

    // Comparación segura para evitar timing attacks
    if (!_constantTimeEquals(computed, receivedHash)) {
      throw const TilopayHashVerificationException();
    }
  }

  /// Construye el query string en el orden exacto requerido por Tilopay.
  String _buildQueryString({
    required String tpt,
    required String externalOrderId,
    required double amount,
    required String currency,
    required String responseCode,
    required String auth,
    required String email,
  }) {
    final formattedAmount = amount.toStringAsFixed(2);
    final params = {
      'api_Key': apiKey,
      'api_user': apiUser,
      'orderId': tpt,
      'external_orden_id': externalOrderId,
      'amount': formattedAmount,
      'currency': currency,
      'responseCode': responseCode,
      'auth': auth,
      'email': email,
    };
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Comparación de strings en tiempo constante para evitar timing attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
