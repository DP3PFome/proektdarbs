<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Collection;

class CollectionController extends Controller
{
    public function index()
    {
        return Collection::all();
    }

    public function store(Request $request)
{
    $validated = $request->validate([
        'title' => 'required|string|max:255',
        'description' => 'nullable|string',
    ]);

    $collection = Collection::create($validated);

    return response()->json($collection, 201);
}

}
