<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::with(['user', 'items.product'])  // Load items too
            ->latest()
            ->paginate(15);

        return response()->json([
            'data' => $orders->map(fn($order) => [
                'id'             => $order->id,
                'order_number'   => $order->order_number,
                'cashier'        => $order->user?->name ?? 'Unknown',
                'date'           => $order->created_at->format('Y-m-d H:i:s'), // Better format for Flutter
                'grand_total'    => $order->grand_total,
                'payment_method' => $order->payment_method,
                'status'         => $order->status,
                'items_count'    => $order->items->count(),
            ]),
            'meta' => [
                'total'        => $orders->total(),
                'current_page' => $orders->currentPage(),
                'last_page'    => $orders->lastPage(),
            ],
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $order = Order::with(['user', 'items.product'])->findOrFail($id);

        return response()->json([
            'data' => [
                'id'             => $order->id,
                'order_number'   => $order->order_number,
                'cashier'        => $order->user?->name ?? 'Unknown',
                'date'           => $order->created_at->format('Y-m-d H:i:s'),
                'grand_total'    => $order->grand_total,
                'discount'       => $order->discount ?? 0,
                'payment_method' => $order->payment_method,
                'status'         => $order->status,
                'items'          => $order->items->map(fn($item) => [
                    'name'     => $item->product_name,
                    'price'    => $item->product_price,
                    'quantity' => $item->quantity,
                    'subtotal' => $item->subtotal,
                    'image'    => $item->product?->image_url ?? null,   // Important for image
                ]),
            ],
        ]);
    }
}