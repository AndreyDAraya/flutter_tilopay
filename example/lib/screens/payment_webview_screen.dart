import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Pantalla WebView que muestra el formulario hospedado de Tilopay.
///
/// Tilopay redirige al usuario de vuelta a la URL configurada en
/// [ProcessPaymentRequest.redirect] al completar el pago.
/// Interceptamos esa URL para extraer los parámetros del resultado.
class PaymentWebviewScreen extends StatefulWidget {
  const PaymentWebviewScreen({
    super.key,
    required this.url,
    required this.orderNumber,
  });

  final String url;
  final String orderNumber;

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;

    // Detectar la URL de retorno de Tilopay
    final isReturnUrl = uri.host.contains('example.com') &&
        uri.path.contains('/pago/retorno');

    if (isReturnUrl) {
      _processReturnUrl(uri);
      return NavigationDecision.prevent;
    }

    // Detectar cancelación explícita
    if (request.url.contains('wp_cancel=yes')) {
      if (mounted) {
        context.go('/payment/result', extra: {
          'success': false,
          'message': 'Pago cancelado por el usuario.',
          'orderNumber': widget.orderNumber,
          'auth': null,
        });
      }
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _processReturnUrl(Uri uri) {
    final params = uri.queryParameters;
    final code = params['code'] ?? '0';
    final auth = params['auth'];
    final description = params['description'] ?? '';
    final success = code == '1';

    if (mounted) {
      context.go('/payment/result', extra: {
        'success': success,
        'message': success
            ? (description.isNotEmpty ? description : 'Pago aprobado correctamente')
            : (description.isNotEmpty ? description : 'El pago no fue aprobado'),
        'orderNumber': params['order'] ?? widget.orderNumber,
        'auth': auth,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Pago Seguro',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _mostrarDialogoCancelacion(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.lock_rounded, size: 18, color: Colors.white70),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const ColoredBox(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF1A237E),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando pasarela de pago...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoCancelacion() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar pago?'),
        content: const Text(
          'Si sales ahora, el pago no se completará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/payment/result', extra: {
                'success': false,
                'message': 'Pago cancelado.',
                'orderNumber': widget.orderNumber,
                'auth': null,
              });
            },
            child: const Text('Cancelar pago', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
