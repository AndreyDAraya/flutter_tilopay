# tilopay

SDK oficial de [Tilopay](https://tilopay.com) para Flutter.

Integra el gateway de pagos Tilopay en tu app Flutter con soporte completo para:

- **Flujo Redirect** — redirige al usuario al formulario hospedado de Tilopay
- **Flujo Nativo (FAC)** — procesa pagos directamente con token de tarjeta
- **Autenticación 3D Secure (3DS)** — challenge inline via WebView
- **Pagos recurrentes / suscripciones** — cobros con tarjeta tokenizada
- **Modificaciones** — captura, reembolso y reverso de pagos
- **Tokenización de tarjetas** — guarda tarjetas para uso futuro
- **Verificación HMAC-SHA256** — valida webhooks y callbacks de retorno
- **Métodos alternativos** — SINPE Móvil (CR), Yappy (PA), Apple Pay

## Instalación

```yaml
dependencies:
  tilopay: ^1.0.0
```

```dart
import 'package:tilopay/tilopay.dart';
```

## Configuración

```dart
final client = TilopayClient(
  config: TilopayConfig(
    apiKey: 'tu-api-key',
    apiUser: 'tu-api-user',
    apiPassword: 'tu-api-password',
  ),
);
```

Para pruebas, configurá el entorno sandbox con tus credenciales de prueba:

```dart
final client = TilopayClient(
  config: TilopayConfig(
    apiKey: 'tu-api-key-sandbox',
    apiUser: 'tu-api-user-sandbox',
    apiPassword: 'tu-api-password-sandbox',
    environment: TilopayEnvironment.sandbox,
  ),
);
```

## Flujo Redirect

El usuario es redirigido al formulario hospedado de Tilopay. Al completar, vuelve a tu app con los parámetros del resultado.

```dart
// 1. Autenticar
final auth = await client.login();

// 2. Iniciar pago
final response = await client.processPayment(
  accessToken: auth.accessToken,
  request: ProcessPaymentRequest(
    key: client.config.apiKey,
    amount: 15000,
    currency: 'CRC',
    orderNumber: 'ORD-001',
    captureMode: CaptureMode.captureNow,
    redirect: 'https://mitienda.com/pago/retorno',
    billing: BillingInfo(
      firstName: 'Juan',
      lastName: 'Pérez',
      email: 'juan@example.com',
    ),
  ),
);

if (response.needsRedirect) {
  // Abrir response.redirectUrl en un WebView o browser externo
}
```

### Verificar el retorno

Cuando el usuario vuelve a tu app, verificá la autenticidad del callback:

```dart
final params = RedirectCallbackParams.fromQueryParams(uri.queryParameters);

final verifier = TilopayHashVerifier(
  apiKey: config.apiKey,
  apiUser: config.apiUser,
  apiPassword: config.apiPassword,
);

// Lanza TilopayHashVerificationException si el hash no es válido
verifier.verifyRedirectCallback(
  params: params,
  amount: 15000.00,
  currency: 'CRC',
  email: 'juan@example.com',
);

if (params.isApproved) {
  // Orden confirmada — auth: params.auth
}
```

## Flujo Nativo (FAC)

El formulario de pago corre embebido. La tarjeta se tokeniza en el cliente mediante el SDK de Tilopay y nunca llega a tu servidor.

```dart
// 1. Autenticar con loginSdk para inicializar el SDK de Tilopay
final auth = await client.loginSdk();

// 2. Inicializar el SDK de Tilopay en un WebView con auth.accessToken
//    El SDK renderiza el formulario y devuelve el cardToken encriptado.

// 3. Procesar el pago con el token
final response = await client.processPaymentFac(
  request: ProcessPaymentFacRequest(
    key: client.config.apiKey,
    amount: 15000,
    currency: 'CRC',
    billing: BillingInfo(
      firstName: 'Juan',
      lastName: 'Pérez',
      email: 'juan@example.com',
    ),
    orderNumber: 'ORD-001',
    captureMode: CaptureMode.captureNow,
    sessionId: 'APP-${DateTime.now().millisecondsSinceEpoch}',
    redirect: 'https://mitienda.com/pago/retorno',
    cardToken: cardTokenDelSdk,
  ),
);

if (response.isApproved) {
  // Pago aprobado — response.auth contiene el código de autorización
} else if (response.needs3dsChallenge) {
  // Mostrar response.htmlFormData en un WebView para el challenge 3DS
} else if (response.needsTokenex) {
  // Reintento via TokenEx (automático)
  final retryResponse = await client.processPaymentTokenex(
    rawResponse: response.rawJson!,
  );
}
```

## Pagos Recurrentes

Para cobrar suscripciones usando la tarjeta guardada de un pago anterior:

```dart
final auth = await client.login();

final response = await client.processRecurrentPayment(
  accessToken: auth.accessToken,
  request: ProcessRecurrentPaymentRequest(
    key: client.config.apiKey,
    amount: 5000,
    currency: 'USD',
    email: 'juan@example.com',
    orderNumber: 'SUB-002',
    captureMode: CaptureMode.captureNow,
    cardToken: savedCardToken, // token 'crd' del pago original
  ),
);
```

## Modificaciones (Captura / Reembolso / Reverso)

```dart
final auth = await client.login();

// Capturar un pago previamente autorizado
await client.processModification(
  accessToken: auth.accessToken,
  request: ProcessModificationRequest(
    orderNumber: 'ORD-001',
    key: client.config.apiKey,
    amount: 15000,
    type: ModificationType.capture,
  ),
);

// Reembolsar
await client.processModification(
  accessToken: auth.accessToken,
  request: ProcessModificationRequest(
    orderNumber: 'ORD-001',
    key: client.config.apiKey,
    amount: 15000,
    type: ModificationType.refund,
  ),
);
```

> La captura debe realizarse dentro de los **7 días calendario** desde la autorización.

## Tokenización de Tarjetas

Guardá la tarjeta del usuario para pagos futuros:

```dart
final auth = await client.login();

// Abre un WebView donde el usuario ingresa su tarjeta de forma segura
final result = await client.processTokenize(
  context,
  accessToken: auth.accessToken,
  request: ProcessTokenizeRequest(
    key: client.config.apiKey,
    orderNumber: 'TOKEN-001',
    redirect: 'https://mitienda.com/tokenize/retorno',
  ),
);

if (result != null && result.isSuccess) {
  final savedToken = result.cardToken; // Guardar para pagos futuros
}
```

## Webhook — Verificación de Autenticidad

```dart
final notification = WebhookNotification.fromJson(requestBody);

final verifier = TilopayHashVerifier(
  apiKey: config.apiKey,
  apiUser: config.apiUser,
  apiPassword: config.apiPassword,
);

// Lanza TilopayHashVerificationException si el hash no es válido
verifier.verifyWebhook(
  notification: notification,
  amount: 15000.00,
  currency: 'CRC',
  email: 'juan@example.com',
);

if (notification.isApproved) {
  // Actualizar estado de la orden
}
```

## Manejo de Errores

El SDK lanza excepciones tipadas para cada categoría de error:

```dart
try {
  await client.processPayment(...);
} on TilopayAuthException catch (e) {
  // Credenciales inválidas o token expirado
} on TilopayLicenseException catch (e) {
  // Plan inactivo o límite de transacciones alcanzado
} on TilopayNetworkException catch (e) {
  // Timeout, sin conexión o error HTTP — e.statusCode
} on TilopayHashVerificationException {
  // Notificación no auténtica — ignorar
} on TilopayException catch (e) {
  // Error genérico de Tilopay — e.message, e.code
}
```

## Métodos de Pago Soportados

| Método | Región |
|---|---|
| Visa / Mastercard / AmEx | General |
| SINPE Móvil | Costa Rica |
| Yappy | Panamá |
| Apple Pay | General |
| BAC Tasa Cero / Minicuotas | Centroamérica |
| Credix | General |
| Sistema Clave | General |

## Seguridad

- **PCI DSS compliant** — los datos de tarjeta nunca llegan a tu servidor
- **3D Secure 2.0** — autenticación bancaria incluida
- **HMAC-SHA256** — verificación de autenticidad en tiempo constante
- **SSL/HTTPS** — requerido por el gateway

## Entornos

```dart
// Producción (default)
TilopayConfig(
  apiKey: 'tu-api-key',
  apiUser: 'tu-api-user',
  apiPassword: 'tu-api-password',
  environment: TilopayEnvironment.production,
)

// Sandbox — sin encriptación real de tarjetas
TilopayConfig(
  apiKey: 'tu-api-key-sandbox',
  apiUser: 'tu-api-user-sandbox',
  apiPassword: 'tu-api-password-sandbox',
  environment: TilopayEnvironment.sandbox,
)
```

## Licencia

MIT — ver [LICENSE](LICENSE).
