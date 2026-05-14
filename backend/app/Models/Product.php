<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\OrderItem;
class Product extends Model

{
    use SoftDeletes;

    protected $fillable = [
        'category_id', 'name', 'slug', 'description',
        'price', 'stock', 'image_path', 'rating', 'is_active',
    ];

    protected $casts = [
        'price'     => 'decimal:2',
        'rating'    => 'decimal:1',
        'stock'     => 'integer',
        'is_active' => 'boolean',
    ];

    protected $appends = ['image_url', 'stock_status'];

    protected static function boot(): void
    {
        parent::boot();
        static::creating(function ($product) {
            $product->slug = Str::slug($product->name);
        });
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function getImageUrlAttribute(): string
    {
        if ($this->image_path) {
            return Storage::disk('public')->url($this->image_path);
        }
        return asset('images/placeholder.png');
    }

    public function getStockStatusAttribute(): string
    {
        if ($this->stock <= 0) return 'out_of_stock';
        if ($this->stock <= 5) return 'low_stock';
        return 'in_stock';
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeInCategory($query, $categorySlug)
    {
        if ($categorySlug && $categorySlug !== 'all') {
            return $query->whereHas('category', fn($q) =>
                $q->where('slug', $categorySlug)
            );
        }
        return $query;
    }

    public function scopeSearch($query, $term)
    {
        if ($term) {
            return $query->where('name', 'like', "%{$term}%")
                         ->orWhere('description', 'like', "%{$term}%");
        }
        return $query;
    }

    public function orderItems(): HasMany
    {
    return $this->hasMany(OrderItem::class);
    }
    
}

