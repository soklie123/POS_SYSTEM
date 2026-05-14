<?php

use App\Http\Controllers\Admin;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Cashier;
use Illuminate\Support\Facades\Route;

// ── Auth (Public) ─────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('login',  [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])
        ->middleware('auth:sanctum');
});

// ── Cashier ───────────────────────────────────────────
Route::prefix('cashier')
    ->middleware('auth:sanctum')
    ->group(function () {
        Route::get('products',      [Cashier\ProductController::class,  'index']);
        Route::get('products/{id}', [Cashier\ProductController::class,  'show']);
        Route::get('categories',    [Cashier\CategoryController::class, 'index']);
        Route::get('orders',        [Cashier\OrderController::class,    'index']);
        Route::post('orders',       [Cashier\OrderController::class,    'store']);
        Route::get('orders/{id}',   [Cashier\OrderController::class,    'show']);
    });

// ── Admin ─────────────────────────────────────────────
Route::prefix('admin')
    ->middleware('auth:sanctum')
    ->group(function () {
        Route::apiResource('products', Admin\ProductController::class);
        Route::apiResource( 'categories',Admin\CategoryController::class);
        Route::get('dashboard', [Admin\DashboardController::class, 'index']);
        Route::get('orders',    [Admin\OrderController::class,    'index']);
        Route::get('orders/{id}', [Admin\OrderController::class,  'show']);
        Route::get('users',     [Admin\UserController::class,     'index']);
        Route::post('users',    [Admin\UserController::class,     'store']);
        Route::put('users/{id}', [Admin\UserController::class,   'update']);
    });