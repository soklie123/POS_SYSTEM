<?php
namespace App\Services;

use App\Repositories\UserRepository;

class AuthService
{
    public function __construct(
        private UserRepository $user_Repository
    ) {}

    public function login(array $credentials): array
    {
        if (!$this->user_Repository->attempt($credentials)) {
            throw new \Exception('Invalid email or password');
        }

        $user  = $this->user_Repository->getAuthUser();
        $token = $user->createToken('cashier-token')->plainTextToken;

        return [
            'token' => $token,
            'user'  => $user,
        ];
    }

    public function logout($request): void
    {
        $request->user()->currentAccessToken()->delete();
    }
}