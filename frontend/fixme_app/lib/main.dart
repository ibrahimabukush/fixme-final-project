import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_screen.dart';

void main() {
  runApp(const FixMeApp());
}

class FixMeApp extends StatelessWidget {
  const FixMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixMe',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // 👇 هون نقرأ الـ role من arguments ونمرّره للـ SignupScreen
        '/signup': (context) {
          final arg = ModalRoute.of(context)!.settings.arguments;
          final initialRole =
              (arg is String && (arg == 'CUSTOMER' || arg == 'PROVIDER'))
                  ? arg
                  : 'CUSTOMER';
          return SignupScreen(initialRole: initialRole);
        },
        '/verify': (context) => const VerifyScreen(),
        // customerHome و providerHome زي ما عندك
      },
    );
  }
}
