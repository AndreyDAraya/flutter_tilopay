import 'package:flutter_test/flutter_test.dart';
import 'package:tilopay/tilopay.dart';

void main() {
  group('TilopayConfig', () {
    test('config con valores custom', () {
      const config = TilopayConfig(
        apiKey: 'my-key',
        apiUser: 'my-user',
        apiPassword: 'my-pass',
      );
      expect(config.apiKey, 'my-key');
      expect(config.defaultLocale, 'es-CR');
      expect(config.baseUrl, 'https://app.tilopay.com');
    });

    test('entorno sandbox usa la misma base URL', () {
      const config = TilopayConfig(
        apiKey: 'my-key',
        apiUser: 'my-user',
        apiPassword: 'my-pass',
        environment: TilopayEnvironment.sandbox,
      );
      expect(config.environment, TilopayEnvironment.sandbox);
      expect(config.baseUrl, 'https://app.tilopay.com');
    });
  });

  group('BillingInfo', () {
    test('toJson omite campos nulos', () {
      const billing = BillingInfo(
        firstName: 'Juan',
        lastName: 'Pérez',
        email: 'juan@example.com',
      );
      final json = billing.toJson();
      expect(json['billToFirstName'], 'Juan');
      expect(json['billToLastName'], 'Pérez');
      expect(json['billToEmail'], 'juan@example.com');
      expect(json.containsKey('billToCity'), isFalse);
      expect(json.containsKey('billToAddress'), isFalse);
    });
  });

  group('ProcessPaymentRequest', () {
    test('toJson incluye hashVersion V2 siempre', () {
      final request = ProcessPaymentRequest(
        key: 'test-key',
        amount: 15000,
        currency: 'CRC',
        orderNumber: 'ORD-001',
        captureMode: CaptureMode.captureNow,
        redirect: 'https://example.com/retorno',
      );
      final json = request.toJson();
      expect(json['hashVersion'], 'V2');
      expect(json['capture'], 1);
      expect(json['amount'], 15000);
    });

    test('subscription se serializa como 1', () {
      final request = ProcessPaymentRequest(
        key: 'test-key',
        amount: 5000,
        currency: 'USD',
        orderNumber: 'SUB-001',
        captureMode: CaptureMode.authorizeOnly,
        redirect: 'https://example.com/retorno',
        subscription: true,
      );
      final json = request.toJson();
      expect(json['subscription'], 1);
      expect(json['capture'], 0);
    });

    test('sin subscription no incluye campo en json', () {
      final request = ProcessPaymentRequest(
        key: 'test-key',
        amount: 5000,
        currency: 'USD',
        orderNumber: 'ORD-002',
        captureMode: CaptureMode.captureNow,
        redirect: 'https://example.com/retorno',
      );
      expect(request.toJson().containsKey('subscription'), isFalse);
    });
  });

  group('ProcessModificationRequest', () {
    test('type captura serializa correctamente', () {
      final request = ProcessModificationRequest(
        orderNumber: 'ORD-001',
        key: 'test-key',
        amount: 15000,
        type: ModificationType.capture,
      );
      expect(request.toJson()['type'], 1);
    });

    test('type reembolso serializa correctamente', () {
      final request = ProcessModificationRequest(
        orderNumber: 'ORD-001',
        key: 'test-key',
        amount: 5000,
        type: ModificationType.refund,
      );
      expect(request.toJson()['type'], 2);
    });

    test('type reverso serializa correctamente', () {
      final request = ProcessModificationRequest(
        orderNumber: 'ORD-001',
        key: 'test-key',
        amount: 15000,
        type: ModificationType.reversal,
      );
      expect(request.toJson()['type'], 3);
    });
  });

  group('PaymentResponse', () {
    test('fromJson type 100 = redirect', () {
      final response = PaymentResponse.fromJson({
        'type': '100',
        'url': 'https://app.tilopay.com/checkout/abc',
      });
      expect(response.type, TilopayResponseType.redirect);
      expect(response.needsRedirect, isTrue);
      expect(response.redirectUrl, 'https://app.tilopay.com/checkout/abc');
      expect(response.isApproved, isFalse);
    });

    test('fromJson type 200 = approved', () {
      final response = PaymentResponse.fromJson({
        'type': '200',
        'response': '1',
        'auth': '123456',
        'description': 'Aprobado',
        'order_id': 'tpt-abc',
      });
      expect(response.type, TilopayResponseType.approved);
      expect(response.isApproved, isTrue);
      expect(response.auth, '123456');
      expect(response.orderId, 'tpt-abc');
    });

    test('fromJson type 100 con htmlFormData = needs3dsChallenge', () {
      final response = PaymentResponse.fromJson({
        'type': '100',
        'htmlFormData': '<form>...</form>',
      });
      expect(response.needs3dsChallenge, isTrue);
    });

    test('fromJson tipo desconocido = unknown', () {
      final response = PaymentResponse.fromJson({'type': '999'});
      expect(response.type, TilopayResponseType.unknown);
    });
  });

  group('WebhookNotification', () {
    test('fromJson parsea correctamente', () {
      final notification = WebhookNotification.fromJson({
        'orderNumber': 'ORD-001',
        'code': '1',
        'orderHash': 'a' * 64,
        'tpt': 'tpt-internal-id',
        'auth': '654321',
      });
      expect(notification.isApproved, isTrue);
      expect(notification.isPending, isFalse);
      expect(notification.tpt, 'tpt-internal-id');
    });

    test('code Pending = isPending true', () {
      final notification = WebhookNotification.fromJson({
        'orderNumber': 'ORD-002',
        'code': 'Pending',
        'orderHash': 'b' * 64,
        'tpt': 'tpt-xyz',
      });
      expect(notification.isPending, isTrue);
      expect(notification.isApproved, isFalse);
    });
  });

  group('RedirectCallbackParams', () {
    test('fromQueryParams parsea correctamente', () {
      final params = RedirectCallbackParams.fromQueryParams({
        'tpt': 'tpt-abc',
        'order': 'ORD-001',
        'code': '1',
        'OrderHash': 'c' * 64,
        'auth': '111222',
        'description': 'Aprobado',
        'crd': 'saved-card-token',
        'selected_method': 'card',
      });
      expect(params.isApproved, isTrue);
      expect(params.cancelled, isFalse);
      expect(params.cardToken, 'saved-card-token');
    });

    test('wp_cancel yes = cancelled true', () {
      final params = RedirectCallbackParams.fromQueryParams({
        'tpt': 'tpt-abc',
        'order': 'ORD-001',
        'code': '0',
        'OrderHash': 'd' * 64,
        'wp_cancel': 'yes',
      });
      expect(params.cancelled, isTrue);
      expect(params.isApproved, isFalse);
    });
  });

  group('TilopayHashVerifier', () {
    const verifier = TilopayHashVerifier(
      apiKey: 'test-api-key',
      apiUser: 'test-user',
      apiPassword: 'test-password',
    );

    test('computeHash devuelve string de 64 chars', () {
      final hash = verifier.computeHash(
        tpt: 'tpt-test-123',
        externalOrderId: 'ORD-001',
        amount: 15000.00,
        currency: 'CRC',
        responseCode: '1',
        auth: '123456',
        email: 'test@example.com',
      );
      expect(hash.length, 64);
    });

    test('mismo input siempre produce mismo hash', () {
      final hash1 = verifier.computeHash(
        tpt: 'tpt-abc',
        externalOrderId: 'ORD-001',
        amount: 5000.00,
        currency: 'USD',
        responseCode: '1',
        auth: '999888',
        email: 'user@test.com',
      );
      final hash2 = verifier.computeHash(
        tpt: 'tpt-abc',
        externalOrderId: 'ORD-001',
        amount: 5000.00,
        currency: 'USD',
        responseCode: '1',
        auth: '999888',
        email: 'user@test.com',
      );
      expect(hash1, hash2);
    });

    test('hash inválido lanza TilopayHashVerificationException', () {
      final notification = WebhookNotification.fromJson({
        'orderNumber': 'ORD-001',
        'code': '1',
        'orderHash': 'hash-invalido-de-64-chars-${'0' * 39}',
        'tpt': 'tpt-abc',
        'auth': '123456',
      });

      expect(
        () => verifier.verifyWebhook(
          notification: notification,
          amount: 15000.00,
          currency: 'CRC',
          email: 'test@example.com',
        ),
        throwsA(isA<TilopayHashVerificationException>()),
      );
    });

    test('hash con menos de 64 chars lanza excepción inmediatamente', () {
      final notification = WebhookNotification.fromJson({
        'orderNumber': 'ORD-001',
        'code': '1',
        'orderHash': 'corto',
        'tpt': 'tpt-abc',
      });

      expect(
        () => verifier.verifyWebhook(
          notification: notification,
          amount: 100.00,
          currency: 'USD',
          email: 'test@example.com',
        ),
        throwsA(isA<TilopayHashVerificationException>()),
      );
    });
  });

  group('Enums', () {
    test('CaptureMode.captureNow.value == 1', () {
      expect(CaptureMode.captureNow.value, 1);
    });

    test('CaptureMode.authorizeOnly.value == 0', () {
      expect(CaptureMode.authorizeOnly.value, 0);
    });

    test(
      'TilopayResponseType.fromString devuelve unknown para valor inexistente',
      () {
        expect(
          TilopayResponseType.fromString('999'),
          TilopayResponseType.unknown,
        );
      },
    );

    test('TilopayResponseType.fromString null devuelve unknown', () {
      expect(TilopayResponseType.fromString(null), TilopayResponseType.unknown);
    });
  });
}
