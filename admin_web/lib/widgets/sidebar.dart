import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pointsell',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          // Nav Items
          _navItem(
            context,
            Icons.dashboard_outlined,
            'Dashboard',
            '/dashboard',
          ),
          _navItem(
            context,
            Icons.inventory_2_outlined,
            'Products',
            '/products',
          ),
          _navItem(
            context,
            Icons.category_outlined,
            'Categories',
            '/categories',
          ),
          _navItem(context, Icons.receipt_long_outlined, 'Orders', '/orders'),
          _navItem(context, Icons.people_outline, 'Users', '/users'),
          _navItem(context, Icons.receipt_long_outlined, 'report', '/report'),

          const Spacer(),
          const Divider(color: Colors.white12),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.white54),
            ),
            onTap: () async {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFF6B00).withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFFF6B00) : Colors.white54,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFFF6B00) : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (route != currentRoute) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
