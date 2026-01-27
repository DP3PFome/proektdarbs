<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CollectionController;
use App\Http\Controllers\Api\ItemController;

Route::get('/collections', [CollectionController::class, 'index']);
Route::get('/collections/{id}', [CollectionController::class, 'show']);
Route::post('/collections', [CollectionController::class, 'store']);

Route::post('/items', [ItemController::class, 'store']);
