<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;//Defines which fields can be  saved to database Protects against hackers
use Illuminate\Database\Eloquent\Attributes\Hidden;//Hides fields from API response
use Illuminate\Foundation\Auth\User as Authenticatable;//Enable login features
use Laravel\Sanctum\HasApiTokens; //Create login tokens
#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    use HasApiTokens; // add HasApiTokens here

    protected function casts(): array//automatic conversion
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}