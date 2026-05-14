<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'name'            => $this->name,
            'description'     => $this->description,
            'price'           => number_format($this->price, 2, '.', ''),
            'price_formatted' => '$' . number_format($this->price, 2),
            'image_url' => $this->image_url,
            'image_url_thumb' => $this->image_url, 
            'rating'          => number_format($this->rating, 1),
            'stock'           => $this->stock,
            'stock_status'    => $this->stock_status,
            'category'        => [
                'id'    => $this->category->id,
                'name'  => $this->category->name,
                'slug'  => $this->category->slug,
                'color' => $this->category->color,
            ],
            'updated_at' => $this->updated_at,
        ];
    }
}