import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'exceptions/tilopay_exception.dart';
import 'models/auth/auth_response.dart';
import 'models/auth/login_request.dart';
import 'models/auth/login_sdk_request.dart';
import 'models/payment/payment_response.dart';
import 'models/payment/process_modification_request.dart';
import 'models/payment/process_payment_fac_request.dart';
import 'models/payment/process_payment_request.dart';
import 'models/payment/process_recurrent_payment_request.dart';
import 'models/payment/process_tokenize_request.dart';
import 'models/payment/remove_card_request.dart';
import 'models/payment/tokenize_response.dart';
import 'tilopay_config.dart';
import 'ui/tilopay_tokenize_webview.dart';

/// Cliente principal para interactuar con la API de Tilopay.
///
/// ## Uso básico — Flujo Redirect
/// ```dart
/// final config = TilopayConfig(
///   apiKey: 'tu-api-key',
///   apiUser: 'tu-api-user',
///   apiPassword: 'tu-api-password',
///   debugLog: true, // Habilitar logs de red
/// );
///
/// final client = TilopayClient(config: config);
///
/// // 1. Autenticar
/// final auth = await client.login();
///
/// // 2. Iniciar pago — redirige al formulario hospedado de Tilopay
/// final response = await client.processPayment(
///   accessToken: auth.accessToken,
///   request: ProcessPaymentRequest(
///     key: config.apiKey, // Usar la misma clave que la config
///     amount: 15000,
///     currency: 'CRC',
///     orderNumber: 'ORD-001',
///     captureMode: CaptureMode.captureNow,
///     redirect: 'https://mitienda.com/pago/retorno',
///   ),
/// );
///
/// if (response.needsRedirect) {
///   // Abrir response.redirectUrl en un WebView o browser
/// }
/// ```
///
/// ## Uso básico — Flujo Nativo
/// ```dart
/// // 1. Autenticar con loginSdk para el SDK de frontend
/// final auth = await client.loginSdk();
///
/// // El SDK de Tilopay (JS) corre en un WebView y devuelve
/// // el cardToken encriptado. Luego:
///
/// // 2. Procesar pago nativo con el token
/// final response = await client.processPaymentFac(
///   request: ProcessPaymentFacRequest(
///     key: config.apiKey,
///     amount: 15000,
///     currency: 'CRC',
///     billing: BillingInfo(firstName: 'Juan', lastName: 'Pérez', email: 'juan@example.com'),
///     orderNumber: 'ORD-001',
///     captureMode: CaptureMode.captureNow,
///     sessionId: 'APP-${DateTime.now().millisecondsSinceEpoch}',
///     redirect: 'https://mitienda.com/pago/retorno',
///     cardToken: 'token-del-sdk',
///   ),
/// );
/// ```
class TilopayClient {
  TilopayClient({required this.config}) : _dio = _buildDio(config);

  final TilopayConfig config;
  final Dio _dio;

  // ─── AUTENTICACIÓN ────────────────────────────────────────────────────────

  /// [POST /api/v1/login] — Autentica para el flujo redirect.
  ///
  /// Devuelve un [AuthResponse] con el `access_token` Bearer.
  Future<AuthResponse> login() async {
    final request = LoginRequest(
      email: config.apiUser,
      password: config.apiPassword,
    );
    final data = await _post('/api/v1/login', body: request.toJson());
    return AuthResponse.fromJson(data);
  }

  /// [POST /api/v1/loginSdk] — Autentica para inicializar el SDK nativo.
  ///
  /// Devuelve un [AuthResponse] con el `access_token` y `expires_in`.
  Future<AuthResponse> loginSdk() async {
    final request = LoginSdkRequest(
      apiUser: config.apiUser,
      password: config.apiPassword,
      key: config.apiKey,
    );
    final data = await _post('/api/v1/loginSdk', body: request.toJson());
    return AuthResponse.fromJson(data);
  }

  // ─── PAGOS ────────────────────────────────────────────────────────────────

  /// [POST /api/v1/processPayment] — Inicia un pago en el flujo redirect.
  ///
  /// Requiere [accessToken] obtenido de [login].
  ///
  /// La respuesta típica es [TilopayResponseType.redirect] con la URL al
  /// formulario hospedado de Tilopay. Abrir esa URL en un WebView o browser.
  ///
  /// Cuando el usuario completa el pago, Tilopay redirige a la URL del
  /// merchant con [RedirectCallbackParams] como query parameters.
  Future<PaymentResponse> processPayment({
    required String accessToken,
    required ProcessPaymentRequest request,
  }) async {
    final data = await _post(
      '/api/v1/processPayment',
      body: request.toJson(),
      bearerToken: accessToken,
    );
    return PaymentResponse.fromJson(data);
  }

  /// [POST /admin/processPaymentFAC] — Procesa un pago en el flujo nativo.
  ///
  /// El [ProcessPaymentFacRequest.cardToken] debe ser generado por el SDK
  /// de Tilopay en el cliente. No requiere Authorization header.
  ///
  /// Posibles respuestas:
  /// - [TilopayResponseType.redirect] (`100`) → mostrar challenge 3DS
  ///   ([PaymentResponse.htmlFormData]) en un WebView
  /// - [TilopayResponseType.approved] (`200`) → pago aprobado
  /// - [TilopayResponseType.tokenexRequired] (`400`) → llamar a
  ///   [processPaymentTokenex] con el JSON raw de la respuesta
  Future<PaymentResponse> processPaymentFac({
    required ProcessPaymentFacRequest request,
  }) async {
    final data = await _post(
      '/admin/processPaymentFAC',
      body: request.toJson(),
    );
    return PaymentResponse.fromJson(data);
  }

  /// [POST /admin/processPaymentTokenex] — Reintenta pago via TokenEx.
  ///
  /// Llamar cuando [processPaymentFac] devuelve
  /// [TilopayResponseType.tokenexRequired]. Pasar el [rawResponse] de esa
  /// respuesta. Soporta hasta 3 reintentos recursivos automáticamente.
  Future<PaymentResponse> processPaymentTokenex({
    required Map<String, dynamic> rawResponse,
    int attempt = 1,
  }) async {
    assert(attempt <= 3, 'Máximo 3 reintentos para processPaymentTokenex');

    final data = await _post(
      '/admin/processPaymentTokenex',
      body: {'data': rawResponse},
    );
    final response = PaymentResponse.fromJson(data);

    // Reintento automático (máx 3 veces)
    if (response.needsTokenex && attempt < 3) {
      return processPaymentTokenex(rawResponse: data, attempt: attempt + 1);
    }

    return response;
  }

  /// [POST /api/v1/processRecurrentPayment] — Cobra una suscripción.
  ///
  /// Requiere [accessToken] obtenido de [login] y el token de tarjeta
  /// guardado de un pago anterior (campo `crd` del redirect o `card`
  /// del flujo nativo).
  Future<PaymentResponse> processRecurrentPayment({
    required String accessToken,
    required ProcessRecurrentPaymentRequest request,
  }) async {
    final data = await _post(
      '/api/v1/processRecurrentPayment',
      body: request.toJson(),
      bearerToken: accessToken,
    );
    return PaymentResponse.fromJson(data);
  }

  /// [POST /api/v1/processTokenize] — Inicia proceso de tokenización hospedado.
  ///
  /// Realiza la petición a la API y automáticamente abre un WebView para
  /// que el usuario complete el proceso. Retorna un [TokenizeResponse] con
  /// el resultado, o null si el usuario canceló el proceso.
  Future<TokenizeResponse?> processTokenize(
    BuildContext context, {
    required String accessToken,
    required ProcessTokenizeRequest request,
  }) async {
    final data = await _post(
      '/api/v1/processTokenize',
      body: request.toJson(),
      bearerToken: accessToken,
    );

    final url = data['url']?.toString();
    if (url == null || url.isEmpty) {
      throw const TilopayException(
        'No se recibió una URL de tokenización válida.',
      );
    }

    if (!context.mounted) return null;

    // Abrimos el WebView y esperamos el resultado
    return await Navigator.of(context).push<TokenizeResponse>(
      MaterialPageRoute(
        builder: (ctx) => TilopayTokenizeWebview(
          url: url,
          onResult: (response) {
            Navigator.of(ctx).pop(response);
          },
        ),
      ),
    );
  }

  /// [POST /api/v1/user/card-remove] — Elimina una tarjeta tokenizada.
  ///
  /// Requiere [accessToken] de [login] y la [RemoveCardRequest].
  Future<Map<String, dynamic>> removeCard({
    required String accessToken,
    required RemoveCardRequest request,
  }) async {
    final data = await _post(
      '/api/v1/user/card-remove',
      body: request.toJson(),
      bearerToken: accessToken,
    );
    return data;
  }

  /// [POST /api/v1/processModification] — Captura, reembolsa o reversa.
  ///
  /// Requiere [accessToken] obtenido de [login].
  Future<PaymentResponse> processModification({
    required String accessToken,
    required ProcessModificationRequest request,
  }) async {
    final data = await _post(
      '/api/v1/processModification',
      body: request.toJson(),
      bearerToken: accessToken,
    );
    return PaymentResponse.fromJson(data);
  }

  // ─── INTERNO ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
    String? locale,
  }) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': locale ?? config.defaultLocale,
        if (bearerToken != null) 'Authorization': 'bearer $bearerToken',
      };

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: headers),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw const TilopayException('Respuesta vacía del servidor.');
      }

      _checkForErrors(responseData);
      return responseData;
    } on TilopayException {
      rethrow;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  void _checkForErrors(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final message =
        data['message']?.toString() ??
        data['result']?.toString() ??
        data['error']?.toString() ??
        'Error desconocido de Tilopay';

    switch (type) {
      case '300':
        throw TilopayLicenseException(message, code: type, rawResponse: data);
      case '401':
        throw TilopayAuthException(message, code: type, rawResponse: data);
    }
  }

  Never _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message ?? 'Error de red';

    if (statusCode == 401) {
      throw TilopayAuthException(
        'Token inválido o expirado.',
        code: '401',
        rawResponse: e.response?.data as Map<String, dynamic>?,
      );
    }

    throw TilopayNetworkException(
      message,
      statusCode: statusCode,
      rawResponse: e.response?.data as Map<String, dynamic>?,
    );
  }

  static Dio _buildDio(TilopayConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    if (config.debugLog) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }

  /// Cierra el cliente y libera recursos.
  void close() => _dio.close();
}
