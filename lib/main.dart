import 'package:anantla/screens/home_screen.dart';
import 'package:anantla/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anantla/screens/login_screen.dart';
import 'package:anantla/screens/qr_scanner_screen.dart';
import 'package:anantla/screens/payment_confirmation_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => WalletService(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D30 QR App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), 
      ),
      home: const LoginScreen(), 
      routes: {
        '/home': (context) => const HomeScreen(),
        '/qr_scanner': (context) => const QrScannerScreen(),
        '/confirm_payment': (context) => const PaymentConfirmationScreen(),
      },
    );
  }
}