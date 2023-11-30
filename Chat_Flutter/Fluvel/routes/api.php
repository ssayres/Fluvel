<?php

use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::prefix('auth')->as('auth.')->group(function () {
    Route::post('register', [AuthController::class, 'register'])->name('register');
    Route::post('login', [AuthController::class, 'login'])->name('login');
    Route::post('login_with_token', [AuthController::class, 'loginWihToken'])->name('loginWihToken')
        ->middleware('auth:sanctum')->name('login_with_token');
    Route::get('logout', [authController::class, 'logout'])
        ->middleware('auth:sanctum')
        ->name('logout');
});
