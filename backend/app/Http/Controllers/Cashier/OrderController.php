<?php

namespace App\Http\Controllers\Cashier;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * GET /api/v1/cashier/orders
     * Get cashier's own orders only
     */
    public function index(Request $request): JsonResponse
    {
        $orders = Order::with('items')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(20);

        return response()->json([
            'data' => $orders->map(fn($order) => $this->formatOrder($order)),
            'meta' => [
                'total'        => $orders->total(),
                'current_page' => $orders->currentPage(),
                'last_page'    => $orders->lastPage(),
            ],
        ]);
    }

    /**
     * POST /api/v1/cashier/orders
     * Create new order
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'items'           => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity'   => ['required', 'integer', 'min:1'],
            'discount'        => ['nullable', 'numeric', 'min:0'],
            'payment_method'  => ['required', 'in:cash,qr,card'],
            'amount_received' => ['nullable', 'numeric', 'min:0'],
        ]);

        // Calculate totals
        $subtotal = 0;
        $orderItems = [];

        foreach ($validated['items'] as $item) {
            $product = Product::findOrFail($item['product_id']);
            $itemSubtotal = $product->price * $item['quantity'];
            $subtotal += $itemSubtotal;

            $orderItems[] = [
                'product_id'    => $product->id,
                'product_name'  => $product->name,
                'product_price' => $product->price,
                'quantity'      => $item['quantity'],
                'subtotal'      => $itemSubtotal,
            ];
        }

        $discount   = $validated['discount'] ?? 0;
        $grandTotal = $subtotal - $discount;
        $amountReceived = $validated['amount_received'] ?? 0;
        $change = max(0, $amountReceived - $grandTotal);

        // Create order
        $order = Order::create([
            'user_id'         => $request->user()->id,
            'subtotal'        => $subtotal,
            'discount'        => $discount,
            'grand_total'     => $grandTotal,
            'payment_method'  => $validated['payment_method'],
            'amount_received' => $amountReceived,
            'change_amount'   => $change,
            'status'          => 'synced',
        ]);

        // Create order items
        $order->items()->createMany($orderItems);

        // Update stock
        foreach ($orderItems as $item) {
            Product::where('id', $item['product_id'])
                ->decrement('stock', $item['quantity']);
        }

        return response()->json([
            'message' => 'Order created successfully.',
            'data'    => $this->formatOrder($order->load('items')),
        ], 201);
    }

    /**
     * GET /api/v1/cashier/orders/{id}
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $order = Order::with('items')
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'data' => $this->formatOrder($order),
        ]);
    }

    // ── Format order for Flutter ──────────────
    private function formatOrder(Order $order): array
    {
        return [
            'id'             => $order->id,
            'order_number'   => $order->order_number,
            'date'           => $order->created_at->format('d/m/Y H:i'),
            'subtotal'       => number_format($order->subtotal, 2, '.', ''),
            'discount'       => number_format($order->discount, 2, '.', ''),
            'grand_total'    => number_format($order->grand_total, 2, '.', ''),
            'payment_method' => $order->payment_method,
            'amount_received'=> number_format($order->amount_received, 2, '.', ''),
            'change_amount'  => number_format($order->change_amount, 2, '.', ''),
            'status'         => $order->status,
            'cashier'        => $order->user->name,
            'items'          => $order->items->map(fn($item) => [
                'product_id'    => $item->product_id,
                'product_name'  => $item->product_name,
                'product_price' => number_format($item->product_price, 2, '.', ''),
                'quantity'      => $item->quantity,
                'subtotal'      => number_format($item->subtotal, 2, '.', ''),
            ]),
        ];
    }
}