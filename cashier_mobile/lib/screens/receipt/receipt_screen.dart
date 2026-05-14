import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<int, int> cartItems;
  final List<ProductModel> products;
  final double discount;
  final double grandTotal;
  final String paymentMethod;
  final double amountReceived;
  final double change;

  const ReceiptScreen({
    super.key,
    required this.cartItems,
    required this.products,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.amountReceived,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final orderNumber = now.millisecondsSinceEpoch.toString().substring(7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Receipt',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Success Icon ──────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'Order Confirmed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Order #$orderNumber',
              style: TextStyle(color: Colors.grey[500]),
            ),

            const SizedBox(height: 24),

            // ── Receipt Card ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date & Time ───────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      Text(
                        '${now.day}/${now.month}/${now.year} '
                        '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Payment Method ────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      Text(
                        paymentMethod.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: Colors.black,
                      height: 1,
                      thickness: 1,
                    ),
                  ),

                  // ── Items List ────────────────
                  ...cartItems.entries.map((entry) {
                    final product = products.firstWhere(
                      (p) => p.id == entry.key,
                    );
                    final qty = entry.value;
                    final subtotal = double.parse(product.price) * qty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${product.priceFormatted} x $qty',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
                  const SizedBox(height: 4),

                  // ── Subtotal ──────────────────
                  _receiptRow(
                    'Subtotal',
                    '\$${(grandTotal + discount).toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 6),

                  // ── Discount ──────────────────
                  if (discount > 0)
                    _receiptRow(
                      'Discount',
                      '-\$${discount.toStringAsFixed(2)}',
                      valueColor: Colors.red,
                    ),

                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 6),

                  // ── Grand Total ───────────────
                  _receiptRow(
                    'Grand Total',
                    '\$${grandTotal.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: const Color(0xFFFF6B00),
                  ),

                  // ── Cash fields ───────────────
                  if (paymentMethod == 'cash') ...[
                    const SizedBox(height: 6),
                    _receiptRow(
                      'Cash Received',
                      '\$${amountReceived.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 6),
                    _receiptRow(
                      'Change',
                      '\$${change.toStringAsFixed(2)}',
                      valueColor: Colors.green,
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ────────────────────
            // Print button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print feature coming soon!')),
                  );
                },
                icon: const Icon(
                  Icons.print_outlined,
                  color: Color(0xFFFF6B00),
                ),
                label: const Text(
                  'Print Receipt',
                  style: TextStyle(color: Color(0xFFFF6B00)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6B00)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // New Order button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Go back to product list
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pos',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'New Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(
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
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
