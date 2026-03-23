<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\CustomerController;
use App\Http\Controllers\Admin\OrderController as AdminOrderController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Cashier\ProductController as CashierProductController;
use App\Http\Controllers\Cashier\OrderController as CashierOrderController;
use App\Http\Controllers\Cashier\PaymentController;

// ── Public ────────────────────────────────────────────────────
Route::post('/login',  [AuthController::class,  'login']);

// ── Authenticated ─────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // ── Admin routes ──────────────────────────────────────────
    Route::middleware('role:admin')->prefix('admin')->name('admin.')->group(function () {

        Route::apiResource('categories', CategoryController::class);
        Route::apiResource('products',   ProductController::class);
        Route::apiResource('customers',  CustomerController::class);

        Route::get('orders',                  [AdminOrderController::class, 'index']);
        Route::get('orders/{order}',          [AdminOrderController::class, 'show']);
        Route::patch('orders/{order}/cancel', [AdminOrderController::class, 'cancel']);

        Route::get('reports/sales', [ReportController::class, 'sales']);
    });

    // ── Cashier routes ────────────────────────────────────────
    Route::middleware('role:admin|cashier')->prefix('cashier')->name('cashier.')->group(function () {

        Route::get('products', [CashierProductController::class, 'index']);

        Route::get('orders',                     [CashierOrderController::class, 'index']);
        Route::post('orders',                    [CashierOrderController::class, 'store']);
        Route::post('orders/sync',               [CashierOrderController::class, 'sync']);
        Route::post('orders/{order}/payment',    [PaymentController::class, 'store']);
    });
});
