import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/sidebar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getCategories();
      setState(() => categories = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _deleteCategory(int id, String name, int productCount) async {
    // Show warning if category has products
    if (productCount > 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cannot Delete Category'),
          content: Text(
            'Category "$name" has $productCount product(s).\n\nPlease delete or reassign all products in this category first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Confirm deletion for empty categories
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteCategory(id);
        loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditDialog(dynamic category) {
    final nameController = TextEditingController(text: category['name']);
    final colorController = TextEditingController(text: category['color'] ?? '#FF6B00');
    bool isSaving = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Color (Optional)',
                  hintText: '#FF6B00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter category name'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      
                      setDialogState(() => isSaving = true);
                      
                      try {
                        await ApiService.updateCategory(
                          category['id'], 
                          nameController.text.trim(),
                          color: colorController.text.trim(),
                        );
                        if (mounted) Navigator.pop(context);
                        if (mounted) {
                          loadCategories();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category updated successfully!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#FF6B00');
    bool isSaving = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Color (Optional)',
                  hintText: '#FF6B00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter category name'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      
                      setDialogState(() => isSaving = true);
                      
                      try {
                        await ApiService.createCategory(
                          nameController.text.trim(),
                          color: colorController.text.trim(),
                        );
                        if (mounted) Navigator.pop(context);
                        if (mounted) {
                          loadCategories();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category added successfully!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/categories'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showAddDialog(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Category', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                        : categories.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text('No categories found', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => _showAddDialog(),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                                      child: const Text('Add First Category', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                                  columnSpacing: 24,
                                  columns: const [
                                    DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Product Count', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: List.generate(categories.length, (index) {
                                    final c = categories[index];
                                    final color = _parseColor(c['color']);
                                    final productCount = c['products_count'] ?? 0;
                                    
                                    return DataRow(cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                          ),
                                          Text(c['name']),
                                        ],
                                      )),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: productCount > 0 
                                              ? const Color(0xFFFF6B00).withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$productCount ${productCount == 1 ? "product" : "products"}',
                                          style: TextStyle(
                                            color: productCount > 0 ? const Color(0xFFFF6B00) : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            tooltip: "Edit Category",
                                            icon: const Icon(Icons.edit, color: Color(0xFFFF6B00)),
                                            onPressed: () => _showEditDialog(c),
                                          ),
                                          IconButton(
                                            tooltip: productCount > 0 ? "Cannot delete: Category has products" : "Delete Category",
                                            icon: Icon(Icons.delete, 
                                              color: productCount > 0 ? Colors.grey : Colors.redAccent),
                                            onPressed: productCount > 0 
                                                ? null 
                                                : () => _deleteCategory(c['id'], c['name'], productCount),
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }),
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

  Color _parseColor(String? hex) {
    if (hex == null) return const Color(0xFFFF6B00);
    try {
      String colorStr = hex.replaceAll('#', '');
      if (colorStr.length == 6) {
        return Color(int.parse('FF$colorStr', radix: 16));
      } else if (colorStr.length == 8) {
        return Color(int.parse(colorStr, radix: 16));
      }
      return const Color(0xFFFF6B00);
    } catch (_) {
      return const Color(0xFFFF6B00);
    }
  }
}