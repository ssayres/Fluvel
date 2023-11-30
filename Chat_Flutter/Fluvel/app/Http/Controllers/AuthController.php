<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use GrahamCampbell\ResultType\Success;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Register a user
     * @param RegisterRequest $request
     * @return JsonResponse
     */
    public function register(RegisterRequest $request): JsonResponse {
        
        $data = $request->validated();
    
        $data['password'] = Hash::make($data['password']);
        $data['username'] = strstr($data['email'], '@', true);
    
        // Se o campo username não pôde ser extraído do email, definir o valor do email como username
        if (empty($data['username'])) {
            $data['username'] = $data['email'];
        }
    
        // Criação do usuário com os dados
        $user = User::create([
            'email' => $data['email'],
            'password' => $data['password'],
            'username' => $data['username'],
        ]);
    
        $token = $user->createToken(User::USER_TOKEN);
    
        return $this->success([
            'user' => $user,
            'token' => $token->plainTextToken,
        ], 'Usuário Cadastrado com sucesso');
    }

    /**
     * Login a user
     * @param LoginRequest $request
     * @return JsonResponse
     * 
     */
    public function login(LoginRequest $request) : JsonResponse{
        $isValid = $this->isValidCredential($request);

        if(!$isValid['success']){
            return $this->error($isValid['message'], Response::HTTP_UNPROCESSABLE_ENTITY);

    }

    $user = $isValid['user'];
    $token = $user->createToken(User::USER_TOKEN);

    return $this->success([
        'user' => $user,
        'token' => $token->plainTextToken,

    ], 'Login Successfully !');
}

 /**
     * Validate a user
     * @param LoginRequest $request
     * @return array
     */

    private function isValidCredential(LoginRequest $request): array{

        $data = $request->validated();
        $user = User::where('email', $data['email'])->first();
        if($user == null){
            return [
                'success' => false,
                'message' => 'invalid Credential'
            ];
        }
        if(Hash::check($data['password'], $user->password)){
            return [
                'success' => true,
                'user' =>$user
            ];
        }
        return [
            'success' =>false,
            'message' => 'Senha inválida' 
        ];
    }
    /**
     * Logins a user with token
     * 
     * 
     */
    public function loginWihToken(): JsonResponse{

        return $this->success(auth()->user(),);

    }

    public function logout(Request $request) : JsonResponse{
        $request->user->currentAccessToken()->delete();
        return $this->success(null, 'Logout efetuado');

    }
}
