<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    // POST /api/items
    public function store(Request $request)
    {
        $validated = $request->validate([
            'collection_id' => 'required|exists:collections,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image' => 'nullable|string',
            'year' => 'nullable|integer',
        ]);

        return Item::create($validated);
    }
}
