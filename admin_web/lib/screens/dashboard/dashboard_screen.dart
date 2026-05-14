import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await ApiService.getDashboard();
      setState(() {
        dashboardData = data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/dashboard'),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B00),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back, Admin!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 32),

                        // Summary Cards
                        Row(
                          children: [
                            _summaryCard(
                              'Today\'s Sales',
                              '\$${dashboardData?['today_sales'] ?? '0.00'}',
                              Icons.attach_money,
                              Colors.green,
                            ),
                            const SizedBox(width: 16),
                            _summaryCard(
                              'Total Orders',
                              '${dashboardData?['total_orders'] ?? 0}',
                              Icons.receipt_long,
                              const Color(0xFFFF6B00),
                            ),
                            const SizedBox(width: 16),
                            _summaryCard(
                              'Active Cashiers',
                              '${dashboardData?['total_cashiers'] ?? 0}',
                              Icons.people,
                              Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Top Products
                        const Text(
                          'Top Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTopProducts(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final products = dashboardData?['top_products'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('Product',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                ),
                const Expanded(
                  child: Text('Price',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                ),
                Expanded(
                  child: Text('Sold',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Rows
          ...products.map((p) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(p['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(
                        '\$${p['price']}',
                        style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text('${p['sold']}'),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}