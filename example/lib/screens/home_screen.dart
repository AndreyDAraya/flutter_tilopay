import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:tilopay/tilopay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Tilopay Demo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo / Branding
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tilopay Flutter SDK',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Integración de pagos para Centroamérica',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Productos de ejemplo
              const Text(
                'Productos de demo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              _ProductCard(
                name: 'Plan Básico',
                description: 'Acceso mensual al servicio',
                price: 5000,
                currency: 'CRC',
                icon: Icons.star_outline_rounded,
                onTap: () => context.push(
                  '/checkout',
                  extra: {
                    'name': 'Plan Básico',
                    'amount': 5000.0,
                    'currency': 'CRC',
                  },
                ),
              ),
              const SizedBox(height: 12),
              _ProductCard(
                name: 'Plan Premium',
                description: 'Acceso anual con todas las funciones',
                price: 49,
                currency: 'USD',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF6200EA),
                onTap: () => context.push(
                  '/checkout',
                  extra: {
                    'name': 'Plan Premium',
                    'amount': 49.0,
                    'currency': 'USD',
                  },
                ),
              ),
              const SizedBox(height: 12),
              _ProductCard(
                name: 'Consultoría',
                description: 'Sesión de 1 hora con especialista',
                price: 75,
                currency: 'USD',
                icon: Icons.support_agent_rounded,
                color: const Color(0xFF00796B),
                onTap: () => context.push(
                  '/checkout',
                  extra: {
                    'name': 'Consultoría',
                    'amount': 75.0,
                    'currency': 'USD',
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Opciones avanzadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              _ProductCard(
                name: 'Tokenizar Tarjeta',
                description: 'Flujo Hospedado (Redirect)',
                price: 0,
                currency: 'USD',
                icon: Icons.add_card_rounded,
                color: Colors.blueAccent,
                onTap: () => _iniciarTokenizacion(context),
              ),
              const SizedBox(height: 12),
              _ProductCard(
                name: 'Pago 100% Nativo',
                description: 'Formulario interno + Tokenización',
                price: 99,
                currency: 'USD',
                icon: Icons.app_registration_rounded,
                color: const Color(0xFFD81B60),
                onTap: () => context.push(
                  '/checkout/native',
                  extra: {
                    'name': 'Licencia SDK',
                    'amount': 99.0,
                    'currency': 'USD',
                  },
                ),
              ),
              const SizedBox(height: 12),
              _ProductCard(
                name: 'Eliminar Tarjeta',
                description: 'Quitar token de la bóveda',
                price: 0,
                currency: 'USD',
                icon: Icons.credit_card_off_rounded,
                color: Colors.redAccent,
                onTap: () => context.push('/remove-card'),
              ),
              const SizedBox(height: 32),
              // Badge entorno sandbox
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFE65100),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Modo Sandbox — No se realizan cobros reales',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _iniciarTokenizacion(BuildContext context) async {
    final tilopay = TilopayClient(
      config: TilopayConfig(
        apiKey: dotenv.env['TILOPAY_API_KEY']!,
        apiUser: dotenv.env['TILOPAY_API_USER']!,
        apiPassword: dotenv.env['TILOPAY_API_PASSWORD']!,
        environment: dotenv.env['TILOPAY_ENVIRONMENT'] == 'sandbox'
            ? TilopayEnvironment.sandbox
            : TilopayEnvironment.production,
      ),
    );

    try {
      final auth = await tilopay.login();
      if (!context.mounted) return;
      final response = await tilopay.processTokenize(
        context,
        accessToken: auth.accessToken,
        request: ProcessTokenizeRequest(
          key: tilopay.config.apiKey,
          redirect: 'https://example.com/pago/retorno',
          email: 'andreydaraya@gmail.com',
          firstName: 'Andrey',
          lastName: 'Delgado Araya',
        ),
      );

      if (response != null && context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(response.success ? '¡Éxito!' : 'Error'),
            content: Text(
              response.success
                  ? 'Token: ${response.crd}\nDesc: ${response.description}'
                  : 'Fallo: ${response.description}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      tilopay.close();
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF1A237E),
  });

  final String name;
  final String description;
  final num price;
  final String currency;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency $price',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
