<?php

namespace Modules\UserManagement\Http\Controllers\Api\Customer;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class VitoWalletController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user()->load('userAccount');
        $balance = $user->userAccount?->wallet_balance ?? 0.0;

        $transactions = \Modules\TransactionManagement\Entities\Transaction::where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->limit(20)
            ->get();

        return response()->json(responseFormatter(DEFAULT_200, [
            'balance' => (float) $balance,
            'transactions' => $transactions,
        ]));
    }
}
