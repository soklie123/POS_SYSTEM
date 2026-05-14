import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/sidebar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getUsers();
      setState(() => users = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddCashierDialog() {
    final nameController     = TextEditingController();
    final emailController    = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Cashier'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createUser(
                  name:     nameController.text,
                  email:    emailController.text,
                  password: passwordController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cashier created!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00)),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/users'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text('Cashiers',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _showAddCashierDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Cashier',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Table
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF6B00)))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('Name',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.grey))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('Email',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.grey))),
                                      Expanded(
                                          child: Text('Role',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.grey))),
                                      Expanded(
                                          child: Text('Status',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.grey))),
                                      Expanded(
                                          child: Text('Joined',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.grey))),
                                      SizedBox(width: 80),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // Rows
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: users.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final u = users[index];
                                      final isActive =
                                          u['is_active'] ?? true;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(
                                                                0xFFFF6B00)
                                                            .withOpacity(
                                                                0.1),
                                                    child: Text(
                                                      u['name'][0]
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          color: Color(
                                                              0xFFFF6B00),
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(u['name'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(u['email'],
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600])),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                          0xFFFF6B00)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: const Text(
                                                  'Cashier',
                                                  style: TextStyle(
                                                    color:
                                                        Color(0xFFFF6B00),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  isActive
                                                      ? 'Active'
                                                      : 'Inactive',
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                u['created_at'] ?? '',
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 13),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 80,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color:
                                                        Color(0xFFFF6B00)),
                                                onPressed: () {},
                                                tooltip: 'Edit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}