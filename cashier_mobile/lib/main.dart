import 'package:cashier_mobile/screens/pos/pos_screen.dart';
import 'package:cashier_mobile/screens/splash/splash_screen.dart';
import 'package:cashier_mobile/screens/checkout/checkout_screen.dart';
import 'package:cashier_mobile/screens/receipt/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'screens/Auth/login_screen.dart';
import 'models/product_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashier POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFF5821E),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/pos': (context) => const PosScreen(),
      },
      // ── Dynamic routes (need arguments) ──
      onGenerateRoute: (settings) {
        // ── Checkout Screen ───────────────
        if (settings.name == '/checkout') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CheckoutScreen(
              cartItems: args['cartItems'] as Map<int, int>,
              products: args['products'] as List<ProductModel>,
              discount: args['discount'] as double,
              grandTotal: args['grandTotal'] as double,
            ),
          );
        }

        // ── Receipt Screen ────────────────
        if (settings.name == '/receipt') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              cartItems: args['cartItems'] as Map<int, int>,
              products: args['products'] as List<ProductModel>,
              discount: args['discount'] as double,
              grandTotal: args['grandTotal'] as double,
              paymentMethod: args['paymentMethod'] as String,
              amountReceived: args['amountReceived'] as double,
              change: args['change'] as double,
            ),
          );
        }

        return null;
      },
    );
  }
}
