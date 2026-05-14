import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/sidebar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> products  = [];
  bool isLoading          = true;
  String searchText       = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getProducts(search: searchText);
      if (mounted) setState(() => products = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Debounce search to avoid too many API calls
  void onSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchText = value;
      loadProducts();
    });
  }

  Future<void> deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProduct(id);
        if (mounted) {
          loadProducts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted!'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> showAddProductDialog() async {
    final nameController        = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController       = TextEditingController();
    final stockController       = TextEditingController();
    String? selectedCategoryId;
    List<dynamic> categories    = [];
    Uint8List? imageBytes;
    String? imageFileName;
    bool isSaving               = false;

    try {
      categories = await ApiService.getCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_box_outlined,
                    color: Color(0xFFFF6B00)),
              ),
              const SizedBox(width: 12),
              const Text('Add New Product',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Image Upload Area
                  const Text('Product Image',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        imageQuality: 80,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        setDialogState(() {
                          imageBytes    = bytes;
                          imageFileName = picked.name;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: imageBytes != null
                              ? const Color(0xFFFF6B00)
                              : Colors.grey[300]!,
                          width: imageBytes != null ? 2 : 1,
                        ),
                      ),
                      child: imageBytes != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.memory(
                                    imageBytes!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setDialogState(() {
                                      imageBytes    = null;
                                      imageFileName = null;
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Click to upload image',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('PNG, JPG up to 2MB',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Name
                  _buildLabel('Product Name *'),
                  const SizedBox(height: 6),
                  _buildTextField(nameController, 'e.g. Grill Sandwich'),
                  const SizedBox(height: 12),

                  // Description
                  _buildLabel('Description'),
                  const SizedBox(height: 6),
                  _buildTextField(descriptionController,
                      'e.g. Beetroot, Potato, Bell Pepper',
                      maxLines: 2),
                  const SizedBox(height: 12),

                  // Category
                  _buildLabel('Category *'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      hintText: 'Select category',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFFF6B00), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                    items: categories
                        .map<DropdownMenuItem<String>>((c) =>
                            DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['name']),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedCategoryId = value),
                  ),
                  const SizedBox(height: 12),

                  // Price and Stock
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price *'),
                            const SizedBox(height: 6),
                            _buildTextField(priceController, '0.00',
                                prefix: '\$ ',
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Stock Qty *'),
                            const SizedBox(height: 6),
                            _buildTextField(stockController, '0',
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          stockController.text.isEmpty ||
                          selectedCategoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please fill all required fields!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSaving = true);

                      try {
                        await ApiService.createProduct(
                          name: nameController.text,
                          description: descriptionController.text,
                          categoryId:
                              int.parse(selectedCategoryId!),
                          price: double.parse(priceController.text),
                          stock: int.parse(stockController.text),
                          imageBytes: imageBytes,
                          imageName: imageFileName,
                        );
                        if (context.mounted) Navigator.pop(context);
                        if (mounted) {
                          loadProducts();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Product added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (context.mounted) {
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
                backgroundColor: const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Add Product',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines        = 1,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B00), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/products'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Products',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          Text('${products.length} products total',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      // Search
                      SizedBox(
                        width: 280,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: onSearch,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Refresh button
                      IconButton(
                        onPressed: loadProducts,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add button
                      ElevatedButton.icon(
                        onPressed: showAddProductDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Product',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
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
                        : products.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined,
                                        size: 64, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text('No products found',
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 18)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: showAddProductDialog,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFF6B00)),
                                      child: const Text('Add First Product',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              )
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
                                    // Table Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                      ),
                                      child: const Row(
                                        children: [
                                          SizedBox(width: 56,
                                              child: Text('IMG',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          Expanded(flex: 3,
                                              child: Text('NAME',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          Expanded(
                                              child: Text('CATEGORY',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          Expanded(
                                              child: Text('PRICE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          Expanded(
                                              child: Text('STOCK',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          Expanded(
                                              child: Text('STATUS',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                          SizedBox(width: 100,
                                              child: Text('ACTIONS',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),

                                    // Table Rows
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount: products.length,
                                        separatorBuilder: (_, __) =>
                                            Divider(
                                                height: 1,
                                                color: Colors.grey[100]),
                                        itemBuilder: (context, index) {
                                          final p = products[index];
                                          final isOutOfStock =
                                              p['stock_status'] ==
                                                  'out_of_stock';
                                          final isLowStock =
                                              p['stock_status'] ==
                                                  'low_stock';

                                          return Container(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : Colors.grey[50]
                                                    ?.withOpacity(0.3),
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 20,
                                                  vertical: 10),
                                              child: Row(
                                                children: [
                                                  // Image
                                                  SizedBox(
                                                    width: 56,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                      child: Image.network(
                                                        p['image_url'],
                                                        width: 42,
                                                        height: 42,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_,
                                                                __,
                                                                ___) =>
                                                            Container(
                                                          width: 42,
                                                          height: 42,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[100],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .fastfood,
                                                              size: 18,
                                                              color: Colors
                                                                  .grey[400]),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Name + Description
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          p['name'],
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14),
                                                        ),
                                                        if (p['description'] !=
                                                                null &&
                                                            p['description']
                                                                .isNotEmpty)
                                                          Text(
                                                            p['description'],
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[500],
                                                                fontSize:
                                                                    12),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Category
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: const Color(
                                                                0xFFFF6B00)
                                                            .withOpacity(
                                                                0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20),
                                                      ),
                                                      child: Text(
                                                        p['category']
                                                            ['name'],
                                                        style:
                                                            const TextStyle(
                                                          color: Color(
                                                              0xFFFF6B00),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),

                                                  // Price
                                                  Expanded(
                                                    child: Text(
                                                      p['price_formatted'],
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFFF6B00),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),

                                                  // Stock
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '${p['stock']}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            color: isOutOfStock
                                                                ? Colors.red
                                                                : isLowStock
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .black87,
                                                          ),
                                                        ),
                                                        if (isLowStock)
                                                          const Padding(
                                                            padding: EdgeInsets
                                                                .only(
                                                                    left: 4),
                                                            child: Icon(
                                                                Icons
                                                                    .warning_amber,
                                                                size: 14,
                                                                color: Colors
                                                                    .orange),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Status
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: isOutOfStock
                                                            ? Colors.red
                                                                .withOpacity(
                                                                    0.1)
                                                            : isLowStock
                                                                ? Colors
                                                                    .orange
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Colors
                                                                    .green
                                                                    .withOpacity(
                                                                        0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20),
                                                      ),
                                                      child: Text(
                                                        isOutOfStock
                                                            ? 'Out of Stock'
                                                            : isLowStock
                                                                ? 'Low Stock'
                                                                : 'In Stock',
                                                        style: TextStyle(
                                                          color: isOutOfStock
                                                              ? Colors.red
                                                              : isLowStock
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .green,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),

                                                  // Actions
                                                  SizedBox(
                                                    width: 100,
                                                    child: Row(
                                                      children: [
                                                        Tooltip(
                                                          message: 'Edit',
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                color: Color(
                                                                    0xFFFF6B00),
                                                                size: 20),
                                                            onPressed: () {},
                                                          ),
                                                        ),
                                                        Tooltip(
                                                          message: 'Delete',
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                color: Colors
                                                                    .red,
                                                                size: 20),
                                                            onPressed: () =>
                                                                deleteProduct(
                                                                    p['id'],
                                                                    p['name']),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
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