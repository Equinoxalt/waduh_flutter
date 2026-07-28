import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/hitung_controller.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';

void main() {
  runApp(const WaduhApp());
}

class WaduhApp extends StatelessWidget {
  const WaduhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HitungController()),
      ],
      child: MaterialApp(
        title: 'Waduh',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isLoggedIn ? const HomePage() : const LoginPage();
  }
}