<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // GET ALL
    public function index()
    {
        $categories = Category::withCount('products')->get();

        return response()->json([
            'data' => $categories
        ]);
    }

    // STORE
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'  => 'required|string|max:255',
            'color' => 'nullable|string|max:20',
        ]);

        $category = Category::create([
            'name'  => $validated['name'],
            'color' => $validated['color'] ?? '#FF6B00',
        ]);

        return response()->json([
            'message' => 'Category created successfully',
            'data' => $category
        ], 201);
    }

    // SHOW
    public function show($id)
    {
        $category = Category::withCount('products')->findOrFail($id);

        return response()->json([
            'data' => $category
        ]);
    }

    // UPDATE
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name'  => 'required|string|max:255',
            'color' => 'nullable|string|max:20',
        ]);

        $category->update([
            'name'  => $validated['name'],
            'color' => $validated['color'] ?? '#FF6B00',
        ]);

        return response()->json([
            'message' => 'Category updated successfully',
            'data' => $category
        ]);
    }

    // DELETE
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully'
        ]);
    }
}