<?php

namespace App\Http\Controllers\Api;
use App\Http\Requests\LoginRequest;
use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

//receives request → calls service
// receives valid request
class AuthController extends Controller
{
    //inject service
    public function __construct(
        private AuthService $authService
    )
    {}
   public function login(LoginRequest $request)
    {
        try{
            $result=$this->authService->login(
                $request->only('email','password')
            );
           return response()->json([
                'token'=>$result['token'],
                'user'=>new UserResource($result['user']),
            ]);
        


        }catch(\Exception $e){
            return response()->json([
                'message'=>$e->getMessage()
            ],401);
        }
    }
    // Logout
    public function logout(Request $request)
    {
        $this->authService->logout($request);
        return response()->json(['message' => 'Logged out']);
    }

    // Get current user
    public function me(Request $request)
    {
        return new UserResource($request->user());
    }
}