<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * 
     * 
     * @return JsonResponse
     */
    public function index() : JsonResponse{
        $users = User::where('id', '!=', auth()->user()->id)->get();
        return $this->success($users)
        ;
    }
}
