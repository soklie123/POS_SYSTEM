import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<int, int> cartItems;
  final List<ProductModel> products;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.products,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<int, int> _cartItems;
  String _discountType = 'percent'; // 'percent' or 'fixed'
  double _discountValue = 0;
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cartItems = Map.from(widget.cartItems);
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  // ── Get product by id ─────────────────────
  ProductModel _getProduct(int id) {
    return widget.products.firstWhere((p) => p.id == id);
  }

  // ── Calculations ──────────────────────────
  double get subtotal {
    double total = 0;
    _cartItems.forEach((id, qty) {
      total += double.parse(_getProduct(id).price) * qty;
    });
    return total;
  }

  double get discountAmount {
    if (_discountType == 'percent') {
      return subtotal * (_discountValue / 100);
    }
    return _discountValue;
  }

  double get grandTotal => subtotal - discountAmount;

  // ── Update quantity ───────────────────────
  void _updateQty(int id, int qty) {
    setState(() {
      if (qty <= 0) {
        _cartItems.remove(id);
      } else {
        _cartItems[id] = qty;
      }
    });
  }

  // ── Remove item ───────────────────────────
  void _removeItem(int id) {
    setState(() => _cartItems.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final cartProductIds = _cartItems.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context, _cartItems),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _cartItems.clear());
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),

      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // ── Cart Items List ───────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProductIds.length,
                    itemBuilder: (context, index) {
                      final id = cartProductIds[index];
                      final product = _getProduct(id);
                      final qty = _cartItems[id]!;
                      return _buildCartItem(product, qty);
                    },
                  ),
                ),

                // ── Discount + Summary ────────────────
                _buildSummarySection(),
              ],
            ),
    );
  }

  // ── Cart Item Card ────────────────────────
  Widget _buildCartItem(ProductModel product, int qty) {
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(product.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 65,
                  height: 65,
                  color: Colors.grey[100],
                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceFormatted,
                    style: const TextStyle(
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: \$${(double.parse(product.price) * qty).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),

            // Quantity Stepper
            Row(
              children: [
                _stepperBtn(Icons.remove, () {
                  _updateQty(product.id, qty - 1);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$qty',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _stepperBtn(Icons.add, () {
                  _updateQty(product.id, qty + 1);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  // ── Summary Section ───────────────────────
  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Discount Toggle ───────────────
          Row(
            children: [
              const Text(
                'Discount:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              // Percent button
              _discountTypeBtn('%', 'percent'),
              const SizedBox(width: 8),
              // Fixed button
              _discountTypeBtn('\$', 'fixed'),
              const SizedBox(width: 12),
              // Discount input
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: _discountType == 'percent'
                        ? 'e.g. 10'
                        : 'e.g. 5.00',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _discountValue = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── Price Rows ────────────────────
          _priceRow(
            'Subtotal',
            '\$${subtotal.toStringAsFixed(2)}',
            isNormal: true,
          ),
          const SizedBox(height: 6),
          _priceRow(
            'Discount',
            '-\$${discountAmount.toStringAsFixed(2)}',
            isRed: true,
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          _priceRow(
            'Grand Total',
            '\$${grandTotal.toStringAsFixed(2)}',
            isBold: true,
            isOrange: true,
          ),

          const SizedBox(height: 16),

          // ── Checkout Button ───────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItems: _cartItems,
                            products: widget.products,
                            discount: discountAmount,
                            grandTotal: grandTotal,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Checkout →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountTypeBtn(String label, String type) {
    final isSelected = _discountType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _discountType = type;
          _discountValue = 0;
          _discountController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isNormal = false,
    bool isRed = false,
    bool isBold = false,
    bool isOrange = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isRed
                ? Colors.red
                : isOrange
                ? const Color(0xFFFF6B00)
                : Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  // ── Empty Cart ────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products from the menu',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
