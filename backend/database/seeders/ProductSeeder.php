<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $food  = Category::create(['name' => 'Food',  'color' => '#FF6B00']);
        $drink = Category::create(['name' => 'Drink', 'color' => '#2196F3']);
        $other = Category::create(['name' => 'Other', 'color' => '#9C27B0']);

        Product::create([
            'category_id' => $food->id,
            'name'        => 'Grill Sandwich',
            'description' => 'Beetroot, Potato, Bell Pepper.',
            'price'       => 30.00,
            'stock'       => 50,
            'rating'      => 5.0,
            'image_path'  => 'products/grill_sandwich.jpg',
        ]);

        Product::create([
            'category_id' => $food->id,
            'name'        => 'Chicken Popeyes',
            'description' => 'Beetroot, Potato, Bell Pepper.',
            'price'       => 20.00,
            'stock'       => 30,
            'rating'      => 4.0,
            'image_path'  => 'products/chicken_popeyes.jpg',
        ]);

        Product::create([
            'category_id' => $food->id,
            'name'        => 'Bison Burgers',
            'description' => 'Beetroot, Potato, Bell Pepper.',
            'price'       => 50.00,
            'stock'       => 0,
            'rating'      => 2.0,
            'image_path'  => 'products/bison_burgers.jpg',
        ]);

        Product::create([
            'category_id' => $drink->id,
            'name'        => 'Orange Juice',
            'description' => 'Fresh cold-pressed juice.',
            'price'       => 8.00,
            'stock'       => 100,
            'rating'      => 4.8,
            'image_path'  => 'products/orange_juice.jpg',
        ]);

        Product::create([
            'category_id' => $drink->id,
            'name'        => 'Iced Coffee',
            'description' => 'Espresso over ice with milk.',
            'price'       => 6.50,
            'stock'       => 80,
            'rating'      => 4.3,
            'image_path'  => 'products/iced_coffee.jpg',
        ]);

        Product::create([
            'category_id' => $other->id,
            'name'        => 'Loyalty Card',
            'description' => 'Buy 9 get 1 free.',
            'price'       => 0.00,
            'stock'       => 999,
            'rating'      => 5.0,
            'image_path'  => 'products/loyalty_card.jpg',
        ]);
    }
}