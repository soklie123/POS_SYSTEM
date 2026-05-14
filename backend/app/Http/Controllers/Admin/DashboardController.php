<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        // Today's orders
        $todayOrders = Order::whereDate('created_at', today())->get();
        $todaySales  = $todayOrders->sum('grand_total');
        $totalOrders = $todayOrders->count();

        // Top products
        $topProducts = Product::withCount(['orderItems as sold' => fn($q) =>
            $q->selectRaw('sum(quantity)')])
            ->orderByDesc('sold')
            ->take(5)
            ->get();

        // Total cashiers
        $totalCashiers = User::where('role', 'cashier')->count();

        return response()->json([
            'data' => [
                'today_sales'    => number_format($todaySales, 2),
                'total_orders'   => $totalOrders,
                'total_cashiers' => $totalCashiers,
                'top_products'   => $topProducts->map(fn($p) => [
                    'name'  => $p->name,
                    'sold'  => $p->sold ?? 0,
                    'price' => $p->price,
                ]),
            ],
        ]);
    }
}