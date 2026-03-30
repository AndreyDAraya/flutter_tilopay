import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tilopay/tilopay.dart';

class RemoveCardScreen extends StatefulWidget {
  const RemoveCardScreen({super.key});

  @override
  State<RemoveCardScreen> createState() => _RemoveCardScreenState();
}

class _RemoveCardScreenState extends State<RemoveCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'andreydaraya@gmail.com');
  final _tokenCtrl = TextEditingController();

  bool _loading = false;
  String? _result;

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _tilopay.close();
    super.dispose();
  }

  Future<void> _eliminarTarjeta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      // 1. Iniciar sesión
      final auth = await _tilopay.login();

      // 2. Eliminar tarjeta
      final response = await _tilopay.removeCard(
        accessToken: auth.accessToken,
        request: RemoveCardRequest(
          key: _tilopay.config.apiKey,
          email: _emailCtrl.text.trim(),
          token: _tokenCtrl.text.trim(),
        ),
      );

      setState(() {
        _result = 'Respuesta del servidor:\n$response';
      });
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar Tarjeta Tokenizada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Usa este formulario para eliminar un token existente de la bóveda de Tilopay.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email del Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Token a Eliminar (CRD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _eliminarTarjeta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ELIMINAR TOKEN'),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 32),
                const Divider(),
                const Text(
                  'Resultado:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_result!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
