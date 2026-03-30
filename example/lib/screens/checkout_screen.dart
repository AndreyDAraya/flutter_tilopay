import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:tilopay/tilopay.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  // Cliente Tilopay — credenciales cargadas desde .env
  final _tilopay = TilopayClient(
    config: TilopayConfig(
      apiKey: dotenv.env['TILOPAY_API_KEY']!,
      apiUser: dotenv.env['TILOPAY_API_USER']!,
      apiPassword: dotenv.env['TILOPAY_API_PASSWORD']!,
      environment: dotenv.env['TILOPAY_ENVIRONMENT'] == 'sandbox'
          ? TilopayEnvironment.sandbox
          : TilopayEnvironment.production,
      debugLog: true,
    ),
  );

  Map<String, dynamic> _productInfo = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) _productInfo = extra;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _tilopay.close();
    super.dispose();
  }

  String get _productName => _productInfo['name'] as String? ?? 'Producto';
  double get _amount => (_productInfo['amount'] as double?) ?? 0.0;
  String get _currency => _productInfo['currency'] as String? ?? 'USD';

  String _generateOrderNumber() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'ORD-$timestamp-$suffix';
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // 1. Autenticar
      final auth = await _tilopay.login();

      final orderNumber = _generateOrderNumber();
      final billing = BillingInfo(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telephone: _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
      );

      // 2. Iniciar pago en flujo redirect
      final response = await _tilopay.processPayment(
        accessToken: auth.accessToken,
        request: ProcessPaymentRequest(
          key: _tilopay.config.apiKey,
          amount: _amount,
          currency: _currency,
          orderNumber: orderNumber,
          captureMode: CaptureMode.captureNow,
          // En producción: tu URL deep link o backend URL
          redirect: 'https://example.com/pago/retorno?order=$orderNumber',
          billing: billing,
          platform: 'flutter-redirect',
          lang: 'es-CR',
        ),
      );

      if (!mounted) return;

      if (response.needsRedirect && response.redirectUrl != null) {
        // 3. Abrir WebView con el formulario hospedado de Tilopay
        context.push(
          '/payment/webview',
          extra: {'url': response.redirectUrl!, 'orderNumber': orderNumber},
        );
      } else if (response.isApproved) {
        context.go(
          '/payment/result',
          extra: {
            'success': true,
            'message': response.description ?? 'Pago aprobado',
            'orderNumber': orderNumber,
            'auth': response.auth,
          },
        );
      } else {
        setState(() {
          _errorMessage =
              response.description ?? 'Respuesta inesperada del gateway.';
        });
      }
    } on TilopayAuthException catch (e) {
      setState(() => _errorMessage = 'Error de autenticación: ${e.message}');
    } on TilopayNetworkException {
      setState(
        () => _errorMessage = 'Sin conexión o timeout. Intenta de nuevo.',
      );
    } on TilopayException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Resumen del producto
                _OrderSummaryCard(
                  name: _productName,
                  amount: _amount,
                  currency: _currency,
                ),
                const SizedBox(height: 28),

                // Formulario de datos del cliente
                const Text(
                  'Datos del comprador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                _TilopayTextField(
                  controller: _firstNameCtrl,
                  label: 'Nombre',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                _TilopayTextField(
                  controller: _lastNameCtrl,
                  label: 'Apellido',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa tu apellido'
                      : null,
                ),
                const SizedBox(height: 12),
                _TilopayTextField(
                  controller: _emailCtrl,
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingresa tu email';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _TilopayTextField(
                  controller: _phoneCtrl,
                  label: 'Teléfono (opcional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),

                // Error
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF9A9A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFC62828),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Métodos de pago aceptados
                const _PaymentMethodsBadge(),
                const SizedBox(height: 20),

                // Botón de pago
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _procesarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: const Color(0xFF9FA8DA),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pagar $_currency ${_amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Pago seguro con cifrado SSL • PCI DSS',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.name,
    required this.amount,
    required this.currency,
  });

  final String name;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de orden',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '$currency ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TilopayTextField extends StatelessWidget {
  const _TilopayTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC62828)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _PaymentMethodsBadge extends StatelessWidget {
  const _PaymentMethodsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Aceptamos:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(width: 12),
          _MethodChip('VISA'),
          SizedBox(width: 6),
          _MethodChip('MC'),
          SizedBox(width: 6),
          _MethodChip('AMEX'),
          SizedBox(width: 6),
          _MethodChip('SINPE'),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
