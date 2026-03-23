<?php
namespace App\Repositories;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class UserRepository{
    public function findByEmail(string $email): ?User{
        return User::where('email',$email)->first();
    }
    public function getAuthUser():?User{//Get the currently logged in user
        return Auth::user();
    }
    public function attempt(array $credentials):bool{//Check if email + password match database
        return Auth::attempt($credentials);

    }
}
