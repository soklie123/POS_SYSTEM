import 'package:admin_web/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/users/users_screen.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pointsell Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF6B00),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/products': (context) => const ProductsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
