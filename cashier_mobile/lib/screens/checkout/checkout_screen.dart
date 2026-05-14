import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<int, int> cartItems;
  final List<ProductModel> products;
  final double discount;
  final double grandTotal;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.products,
    required this.discount,
    required this.grandTotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cash'; // cash, qr, card
  double _amountReceived = 0;
  final _cashController = TextEditingController();
  bool _isLoading = false;

  double get change => _amountReceived - widget.grandTotal;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (_paymentMethod == 'cash' && _amountReceived < widget.grandTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount received is less than grand total!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build items list for API
      final items = widget.cartItems.entries.map((entry) {
        return {'product_id': entry.key, 'quantity': entry.value};
      }).toList();

      // Send order to Laravel API
      await ApiService.createOrder(
        items: items,
        discount: widget.discount,
        paymentMethod: _paymentMethod,
        amountReceived: _amountReceived,
      );

      // Navigate to Receipt
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/receipt',
          arguments: {
            'cartItems': widget.cartItems,
            'products': widget.products,
            'discount': widget.discount,
            'grandTotal': widget.grandTotal,
            'paymentMethod': _paymentMethod,
            'amountReceived': _amountReceived,
            'change': change,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order Summary Card ────────────────
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 8),
            _buildOrderSummary(),

            const SizedBox(height: 20),

            // ── Payment Method ────────────────────
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 8),
            _buildPaymentMethods(),

            const SizedBox(height: 20),

            // ── Cash Input (if cash selected) ─────
            if (_paymentMethod == 'cash') ...[
              _buildSectionTitle('Amount Received'),
              const SizedBox(height: 8),
              _buildCashInput(),
              const SizedBox(height: 20),
            ],

            // ── QR Code placeholder ───────────────
            if (_paymentMethod == 'qr') ...[
              _buildQRPlaceholder(),
              const SizedBox(height: 20),
            ],

            // ── Confirm Button ────────────────────
            _buildConfirmButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  // ── Order Summary ─────────────────────────
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Items list
          ...widget.cartItems.entries.map((entry) {
            final product = widget.products.firstWhere(
              (p) => p.id == entry.key,
            );
            final qty = entry.value;
            final subtotal = double.parse(product.price) * qty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${product.name} x$qty',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(),

          // Subtotal
          _summaryRow(
            'Subtotal',
            '\$${(widget.grandTotal + widget.discount).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 4),

          // Discount
          if (widget.discount > 0)
            _summaryRow(
              'Discount',
              '-\$${widget.discount.toStringAsFixed(2)}',
              valueColor: Colors.red,
            ),

          const Divider(),

          // Grand Total
          _summaryRow(
            'Grand Total',
            '\$${widget.grandTotal.toStringAsFixed(2)}',
            isBold: true,
            valueColor: const Color(0xFFFF6B00),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }

  // ── Payment Methods ───────────────────────
  Widget _buildPaymentMethods() {
    return Row(
      children: [
        _paymentBtn('💵', 'Cash', 'cash'),
        const SizedBox(width: 12),
        _paymentBtn('📱', 'QR Code', 'qr'),
        const SizedBox(width: 12),
        _paymentBtn('💳', 'Card', 'card'),
      ],
    );
  }

  Widget _paymentBtn(String emoji, String label, String type) {
    final isSelected = _paymentMethod == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6B00).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF6B00)
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cash Input ────────────────────────────
  Widget _buildCashInput() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Amount received input
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount Received',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B00),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _amountReceived = double.tryParse(value) ?? 0;
              });
            },
          ),

          const SizedBox(height: 16),

          // Change display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: change >= 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change',
                  style: TextStyle(
                    color: change >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${change >= 0 ? change.toStringAsFixed(2) : '0.00'}',
                  style: TextStyle(
                    color: change >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QR Placeholder ────────────────────────
  Widget _buildQRPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Show QR code to customer',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── Confirm Button ────────────────────────
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirm Order ✓',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
