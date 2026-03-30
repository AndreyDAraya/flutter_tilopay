import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../tilopay.dart';

/// WebView para capturar la respuesta del proceso de tokenización.
///
/// Escucha los cambios de URL e invoca el [onResult] cuando detecta
/// los parámetros de retorno del gateway de Tilopay.
class TilopayTokenizeWebview extends StatefulWidget {
  const TilopayTokenizeWebview({
    super.key,
    required this.url,
    required this.onResult,
    this.appBarTitle = 'Tokenizar Tarjeta',
    this.backgroundColor = Colors.white,
    this.appBarBackgroundColor = const Color(0xFF1A237E),
    this.appBarForegroundColor = Colors.white,
    this.loadingIndicatorColor = const Color(0xFF1A237E),
    this.loadingText = 'Cargando pasarela...',
    this.returnUrlPatterns = const ['example.com', '/pago/retorno'],
  });

  /// URL de redirección generada por el proceso de tokenización
  final String url;

  /// Callback que se ejecuta cuando se detecta el retorno y se parsea el `TokenizeResponse`
  final void Function(TokenizeResponse) onResult;

  /// Título del AppBar
  final String appBarTitle;

  /// Color de fondo del Scaffold
  final Color backgroundColor;

  /// Color de fondo del AppBar
  final Color appBarBackgroundColor;

  /// Color de primer plano (título e íconos) del AppBar
  final Color appBarForegroundColor;

  /// Color del indicador de carga
  final Color loadingIndicatorColor;

  /// Texto a mostrar al cargar la pasarela
  final String loadingText;

  /// Patrones que se usan para detectar que la URL actual es la URL de retorno de éxito o error
  final List<String> returnUrlPatterns;

  @override
  State<TilopayTokenizeWebview> createState() => _TilopayTokenizeWebviewState();
}

class _TilopayTokenizeWebviewState extends State<TilopayTokenizeWebview> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;

    // Detectar retorno basado en los patrones configurados
    bool isReturnUrl = widget.returnUrlPatterns.any(
      (pattern) => uri.host.contains(pattern) || uri.path.contains(pattern),
    );

    if (isReturnUrl) {
      _processReturnUrl(uri);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _processReturnUrl(Uri uri) {
    final response = TokenizeResponse.fromQueryParameters(uri.queryParameters);
    widget.onResult(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.appBarBackgroundColor,
        foregroundColor: widget.appBarForegroundColor,
        title: Text(
          widget.appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.lock_rounded,
              size: 18,
              color: widget.appBarForegroundColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            ColoredBox(
              color: widget.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.loadingIndicatorColor,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.loadingText,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
