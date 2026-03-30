import 'package:go_router/go_router.dart';

import '../screens/checkout_screen.dart';
import '../screens/home_screen.dart';
import '../screens/payment_result_screen.dart';
import '../screens/payment_webview_screen.dart';

import '../screens/native_checkout_screen.dart';
import '../screens/remove_card_screen.dart';
import '../screens/tokenize_webview_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/remove-card',
      builder: (context, state) => const RemoveCardScreen(),
    ),
     GoRoute(
      path: '/tokenize/webview',
      builder: (context, state) {
        final url = state.extra as String;
        return TokenizeWebviewScreen(url: url);
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/checkout/native',
      builder: (context, state) => const NativeCheckoutScreen(),
    ),
    GoRoute(
      path: '/payment/webview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PaymentWebviewScreen(
          url: extra['url'] as String,
          orderNumber: extra['orderNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: '/payment/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PaymentResultScreen(
          success: extra['success'] as bool,
          message: extra['message'] as String,
          orderNumber: extra['orderNumber'] as String,
          auth: extra['auth'] as String?,
        );
      },
    ),
  ],
);
