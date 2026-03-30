import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:tilopay/tilopay.dart';

class NativeCheckoutScreen extends StatefulWidget {
  const NativeCheckoutScreen({super.key});

  @override
  State<NativeCheckoutScreen> createState() => _NativeCheckoutScreenState();
}

class _NativeCheckoutScreenState extends State<NativeCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumCtrl = TextEditingController();
  final _expDateCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

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
    _cardNumCtrl.dispose();
    _expDateCtrl.dispose();
    _cvvCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _tilopay.close();
    super.dispose();
  }

  double get _amount => (_productInfo['amount'] as double?) ?? 150.0;
  String get _currency => _productInfo['currency'] as String? ?? 'USD';

  Future<void> _procesarPagoNativo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // En el flujo nativo real, el token de tarjeta lo genera el SDK JS de
      // Tilopay corriendo en un WebView. El SDK encripta la tarjeta en el
      // cliente y devuelve un cardToken seguro. Ver: loginSdk() + WebView.
      //
      // Para este ejemplo de demostración, usamos el número de tarjeta
      // directamente (solo funciona en entorno sandbox sin encriptación real).
      final cardToken = _cardNumCtrl.text.replaceAll(' ', '');

      // Procesar el pago con el token
      final response = await _tilopay.processPaymentFac(
        request: ProcessPaymentFacRequest(
          key: _tilopay.config.apiKey,
          amount: _amount,
          currency: _currency,
          billing: BillingInfo(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
          ),
          orderNumber: 'ORD-NAT-${DateTime.now().millisecondsSinceEpoch}',
          captureMode: CaptureMode.captureNow,
          sessionId: 'SESS-${DateTime.now().millisecondsSinceEpoch}',
          redirect: 'https://tu-app.com/retorno',
          cardToken: cardToken,
          expDate: _expDateCtrl.text.replaceAll('/', ''),
          cvv: _cvvCtrl.text,
          platform: 'flutter-native-example',
        ),
      );

      if (!mounted) return;

      if (response.isApproved) {
        context.go(
          '/payment/result',
          extra: {
            'success': true,
            'message': response.description ?? 'Pago aprobado',
            'orderNumber': response.orderId,
            'auth': response.auth,
          },
        );
      } else {
        setState(() {
          _errorMessage = response.description ?? 'Pago declinado o error.';
        });
      }
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
      appBar: AppBar(title: const Text('Pago Nativo (Interno)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Total: $_currency ${_amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Datos de Facturación
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const Divider(height: 40),
              // Datos de Tarjeta
              TextFormField(
                controller: _cardNumCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '4111 1111 1111 1111',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberFormatter(),
                  LengthLimitingTextInputFormatter(19),
                ],
                validator: (v) => v!.length < 13 ? 'Número inválido' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expDateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Exp (MM/AA)',
                        hintText: '12/25',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardExpirationFormatter(),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (v) => v!.length != 5 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) => v!.length < 3 ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _procesarPagoNativo,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('PAGAR AHORA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
