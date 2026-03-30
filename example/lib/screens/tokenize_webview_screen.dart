import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tilopay/tilopay.dart';

class TokenizeWebviewScreen extends StatelessWidget {
  const TokenizeWebviewScreen({
    super.key,
    required this.url,
    this.onResult,
  });

  final String url;
  final void Function(TokenizeResponse)? onResult;

  @override
  Widget build(BuildContext context) {
    return TilopayTokenizeWebview(
      url: url,
      onResult: (response) {
        if (onResult != null) {
          onResult!(response);
        }

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    response.success ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: response.success ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(response.success ? '¡Éxito!' : 'Error'),
                ],
              ),
              content: Text(response.success 
                  ? 'Tarjeta tokenizada correctamente.\n\nToken (CRD): ${response.crd}\n\nDescripción: ${response.description}'
                  : 'No se pudo tokenizar: ${response.description}'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Entendido', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
