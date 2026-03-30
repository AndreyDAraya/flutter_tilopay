import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'router/app_router.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const TilopayExampleApp());
}

class TilopayExampleApp extends StatelessWidget {
  const TilopayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tilopay Flutter Demo',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
    );
  }
}
