import 'package:flutter/material.dart';
import 'screens/forgot_password_screen.dart';

import 'screens/start_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_screen.dart';

void main() {
  runApp(const FixMeApp());
}

class FixMeApp extends StatelessWidget {
  const FixMeApp({super.key});

  String _readRoleArg(RouteSettings settings, {String fallback = 'CUSTOMER'}) {
    final arg = settings.arguments;
    if (arg is String && (arg == 'CUSTOMER' || arg == 'PROVIDER')) return arg;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: false,
      ),

      // ✅ Start page
      initialRoute: '/',

      // ✅ keep static routes here
      routes: {
        '/': (context) => const StartScreen(),
        '/role': (context) => const RoleSelectionScreen(),
        '/verify': (context) => const VerifyScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
      },

      // ✅ dynamic routes (need arguments)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login': {
            // إذا بدك تقرأ role كمان للـ login، خليه هون
            // final role = _readRoleArg(settings);
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          }

          case '/signup': {
            final role = _readRoleArg(settings);
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => SignupScreen(initialRole: role),
            );
          }

          default:
            return null;
        }
      },
    );
  }
}
