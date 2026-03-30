import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de resultado del pago — aprobado o rechazado.
class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({
    super.key,
    required this.success,
    required this.message,
    required this.orderNumber,
    this.auth,
  });

  final bool success;
  final String message;
  final String orderNumber;
  final String? auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Ícono animado de resultado
              Center(
                child: _ResultIcon(success: success),
              ),
              const SizedBox(height: 32),
              // Título
              Text(
                success ? '¡Pago exitoso!' : 'Pago no aprobado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: success ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              // Detalles de la orden
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Número de orden',
                      value: orderNumber,
                      icon: Icons.receipt_long_outlined,
                    ),
                    if (auth != null && auth!.isNotEmpty) ...[
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Código de autorización',
                        value: auth!,
                        icon: Icons.verified_outlined,
                        valueColor: const Color(0xFF1B5E20),
                      ),
                    ],
                    const Divider(height: 20),
                    _DetailRow(
                      label: 'Estado',
                      value: success ? 'Aprobado' : 'Rechazado',
                      icon: success
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      valueColor: success
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFFB71C1C),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Acciones
              if (success)
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Volver al inicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () => context.go('/checkout', extra: {}),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Intentar de nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Volver al inicio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                    side: const BorderSide(color: Color(0xFF1A237E)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatefulWidget {
  const _ResultIcon({required this.success});
  final bool success;

  @override
  State<_ResultIcon> createState() => _ResultIconState();
}

class _ResultIconState extends State<_ResultIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final bgColor = widget.success ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = widget.success
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 64, color: color),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
