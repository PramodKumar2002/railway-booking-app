import 'package:flutter/material.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/login_page.dart';
import 'package:my_app/screens/otp_verification_page.dart';
import 'package:my_app/screens/register_page.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';

void main() {
  runApp(const RailwayApp());
}

class RailwayApp extends StatelessWidget {
  const RailwayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/otp': (context) {
          final rawArgs = ModalRoute.of(context)?.settings.arguments;
          String email = '';
          String phone = '';
          if (rawArgs is Map) {
            email = rawArgs['email']?.toString() ?? '';
            phone = rawArgs['phone']?.toString() ?? '';
          }
          if (email.isEmpty) {
            email = AuthService.lastRegisteredEmail ?? '';
          }
          if (phone.isEmpty) {
            phone = AuthService.lastRegisteredPhone ?? '';
          }
          return OtpVerificationPage(
            email: email,
            phone: phone,
          );
        },
        '/home': (_) => const HomeScreen(initialTabIndex: 0),
        '/about': (_) => const HomeScreen(initialTabIndex: 1),
        '/journey': (_) => const HomeScreen(initialTabIndex: 2),
        '/booking': (_) => const HomeScreen(initialTabIndex: 3),
        '/contact': (_) => const HomeScreen(initialTabIndex: 4),
      },
    );
  }
}
