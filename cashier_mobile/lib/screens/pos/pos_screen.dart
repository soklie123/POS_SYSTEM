import 'package:cashier_mobile/screens/orders/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
// ADD import at top of file
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  String selectedCategory = 'all';
  bool isLoading = true;
  bool isOffline = false;
  Map<int, int> cartItems = {};

  @override
  void initState() {
    super.initState();
    // Small delay to let screen render first
    Future.delayed(const Duration(milliseconds: 300), () {
      loadData();
    });
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final cats = await ApiService.getCategories();
      final prods = await ApiService.getProducts(category: selectedCategory);
      setState(() {
        categories = cats;
        products = prods;
        isOffline = false;
      });

      // Pre-warm image cache for all products
      for (final product in prods) {
        if (product.imageUrl.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(product.imageUrl), context);
        }
      }
    } catch (e) {
      setState(() => isOffline = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> onSearch(String value) async {
    setState(() => isLoading = true);
    try {
      final prods = await ApiService.getProducts(
        search: value,
        category: selectedCategory,
      );
      setState(() => products = prods);
    } catch (e) {
      setState(() => isOffline = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onCategoryTap(String slug) {
    setState(() => selectedCategory = slug);
    loadData();
  }

  int get totalCartItems => cartItems.values.fold(0, (sum, qty) => sum + qty);

  double get totalCartPrice {
    double total = 0;
    cartItems.forEach((id, qty) {
      final product = products.firstWhere(
        (p) => p.id == id,
        orElse: () => products.first,
      );
      total += double.parse(product.price) * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            _buildHeader(),

            // ── Offline Banner ───────────────────────────
            if (isOffline) _buildOfflineBanner(),

            // ── Search Bar ───────────────────────────────
            _buildSearchBar(),

            // ── Category Pills ───────────────────────────
            _buildCategoryPills(),

            const SizedBox(height: 8),

            // ── Product Grid ─────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadData,
                      color: const Color(0xFFFF6B00),
                      child: products.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.62,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) =>
                                  _buildProductCard(products[index]),
                            ),
                    ),
            ),

            // ── Floating Cart Button ──────────────────────
            if (totalCartItems > 0) _buildCartButton(),
          ],
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'POS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Cart Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                onPressed: () {},
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Offline Banner ────────────────────────────────────
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        '⚠ Offline — showing cached products',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // ── Category Pills ────────────────────────────────────
  Widget _buildCategoryPills() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildPill('All', 'all'),
          ...categories.map((c) => _buildPill(c.name, c.slug)),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String slug) {
    final isSelected = selectedCategory == slug;
    return GestureDetector(
      onTap: () => onCategoryTap(slug),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── Product Card ──────────────────────────────────────
  Widget _buildProductCard(ProductModel product) {
    final isOutOfStock = product.stockStatus == 'out_of_stock';
    final qty = cartItems[product.id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  // ← add "child:" here
                  imageUrl: product.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Price
                    Text(
                      product.priceFormatted,
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Description
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),

                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Add Button or Stepper
                    qty == 0
                        ? SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: isOutOfStock
                                  ? null
                                  : () {
                                      setState(() {
                                        cartItems[product.id] = 1;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isOutOfStock ? 'Out of Stock' : 'Add',
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _stepperBtn(Icons.remove, () {
                                setState(() {
                                  if (qty <= 1) {
                                    cartItems.remove(product.id);
                                  } else {
                                    cartItems[product.id] = qty - 1;
                                  }
                                });
                              }),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              _stepperBtn(Icons.add, () {
                                setState(() {
                                  cartItems[product.id] = qty + 1;
                                });
                              }),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),

          // Out of Stock Overlay
          if (isOutOfStock)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ── Cart Button ───────────────────────────────────────
  Widget _buildCartButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          final updatedCart = await Navigator.push<Map<int, int>>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CartScreen(cartItems: cartItems, products: products),
            ),
          );
          if (updatedCart != null) {
            setState(() => cartItems = updatedCart);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🛒  $totalCartItems items',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              '\$${totalCartPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF6B00),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) async {
        if (index == 1) {
          // Cart
          final updatedCart = await Navigator.push<Map<int, int>>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CartScreen(cartItems: cartItems, products: products),
            ),
          );
          if (updatedCart != null) {
            setState(() => cartItems = updatedCart);
          }
        } else if (index == 2) {
          // My Orders
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          );
        } else if (index == 3) {
          // Profile → Logout
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    const storage = FlutterSecureStorage();
                    await storage.delete(key: 'auth_token');
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
