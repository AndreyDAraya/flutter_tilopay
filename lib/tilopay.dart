/// SDK oficial de Tilopay para Flutter.
///
/// Permite integrar el gateway de pagos Tilopay en aplicaciones Flutter
/// tanto en el flujo **redirect** (formulario hospedado) como en el
/// flujo **nativo/embedded** (formulario inline con SDK de Tilopay).
///
/// ## Inicio rápido
///
/// ```dart
/// import 'package:tilopay/tilopay.dart';
///
/// // Configurar el cliente
/// final client = TilopayClient(
///   config: TilopayConfig(
///     apiKey: 'tu-api-key',
///     apiUser: 'tu-api-user',
///     apiPassword: 'tu-api-password',
///   ),
/// );
///
/// // Autenticar y procesar un pago (flujo redirect)
/// final auth = await client.login();
/// final response = await client.processPayment(
///   accessToken: auth.accessToken,
///   request: ProcessPaymentRequest(
///     key: client.config.apiKey,
///     amount: 15000,
///     currency: 'CRC',
///     orderNumber: 'ORD-001',
///     captureMode: CaptureMode.captureNow,
///     redirect: 'https://mitienda.com/pago/retorno',
///   ),
/// );
///
/// if (response.needsRedirect) {
///   // Abrir response.redirectUrl en un WebView
/// }
/// ```
library;

// Config
export 'src/tilopay_config.dart';

// Client
export 'src/tilopay_client.dart';

// Enums
export 'src/models/enums.dart';

// Auth
export 'src/models/auth/auth_response.dart';
export 'src/models/auth/login_request.dart';
export 'src/models/auth/login_sdk_request.dart';

// Payment
export 'src/models/payment/billing_info.dart';
export 'src/models/payment/payment_response.dart';
export 'src/models/payment/process_modification_request.dart';
export 'src/models/payment/process_payment_fac_request.dart';
export 'src/models/payment/process_payment_request.dart';
export 'src/models/payment/process_recurrent_payment_request.dart';
export 'src/models/payment/process_tokenize_request.dart';
export 'src/models/payment/remove_card_request.dart';
export 'src/models/payment/tokenize_response.dart';

// Webhook
export 'src/models/webhook/webhook_notification.dart';

// Exceptions
export 'src/exceptions/tilopay_exception.dart';

// Utils
export 'src/utils/hash_verifier.dart';

// UI
export 'src/ui/tilopay_tokenize_webview.dart';
