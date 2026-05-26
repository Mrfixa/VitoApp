<?php

namespace Modules\AuthManagement\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Modules\AuthManagement\Entities\QrToken;

class QrTokenController extends Controller
{
    public function generateToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'role' => 'required|in:driver,customer',
        ]);

        if ($validator->fails()) {
            return response()->json(responseFormatter(constant: DEFAULT_400, errors: errorProcessor($validator)), 422);
        }

        do {
            $tokenValue = Str::random(64);
        } while (QrToken::where('token', $tokenValue)->exists());

        $token = QrToken::create([
            'token' => $tokenValue,
            'role' => $request->role,
            'created_by' => $request->user()->id,
            'expires_at' => $request->role === 'customer' ? now()->addHour() : now()->addDays(7),
        ]);

        return response()->json(responseFormatter(DEFAULT_200, [
            'token' => $token->token,
            'role' => $token->role,
            'expires_at' => $token->expires_at->toISOString(),
            'qr_data' => json_encode([
                'token' => $token->token,
                'role' => $token->role,
            ]),
        ]));
    }

    public function validateToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|size:64',
        ]);

        if ($validator->fails()) {
            return response()->json(responseFormatter(constant: DEFAULT_400, errors: errorProcessor($validator)), 422);
        }

        $qrToken = QrToken::with('creator')->where('token', $request->token)->first();

        if (!$qrToken || !$qrToken->isValid()) {
            return response()->json(responseFormatter(constant: DEFAULT_404), 404);
        }

        return response()->json(responseFormatter(DEFAULT_200, [
            'valid' => true,
            'role' => $qrToken->role,
            'driver_name' => optional($qrToken->creator)->first_name . ' ' . optional($qrToken->creator)->last_name,
        ]));
    }

    public function redeemToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|size:64',
        ]);

        if ($validator->fails()) {
            return response()->json(responseFormatter(constant: DEFAULT_400, errors: errorProcessor($validator)), 422);
        }

        $qrToken = DB::transaction(function () use ($request) {
            $token = QrToken::where('token', $request->token)
                ->lockForUpdate()
                ->first();

            if (!$token || !$token->isValid()) {
                return null;
            }

            $token->update([
                'redeemed_at' => now(),
                'redeemed_by' => $request->user()?->id,
            ]);

            return $token;
        });

        if (!$qrToken) {
            return response()->json(responseFormatter(constant: DEFAULT_404), 404);
        }

        return response()->json(responseFormatter(DEFAULT_200, [
            'redeemed' => true,
            'role' => $qrToken->role,
        ]));
    }

    public function validateTokenPublic(string $token): JsonResponse
    {
        $qrToken = DB::transaction(function () use ($token) {
            return QrToken::with('creator')->where('token', $token)
                ->lockForUpdate()
                ->first();
        });

        if (!$qrToken || !$qrToken->isValid()) {
            return response()->json(responseFormatter(constant: DEFAULT_404, errors: [['message' => 'Token is invalid or expired']]), 404);
        }

        $data = [
            'valid' => true,
            'role' => $qrToken->role,
            'driver_name' => optional($qrToken->creator)->first_name . ' ' . optional($qrToken->creator)->last_name,
        ];

        return response()->json(responseFormatter(DEFAULT_200, $data));
    }

    public function revokeToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|size:64',
        ]);

        if ($validator->fails()) {
            return response()->json(responseFormatter(constant: DEFAULT_400, errors: errorProcessor($validator)), 422);
        }

        $token = DB::transaction(function () use ($request) {
            return QrToken::where('token', $request->token)
                ->where('created_by', $request->user()->id)
                ->lockForUpdate()
                ->first();
        });

        if (!$token) {
            return response()->json(responseFormatter(constant: DEFAULT_404), 404);
        }

        $token->update(['is_revoked' => true]);

        return response()->json(responseFormatter(DEFAULT_200));
    }

    public function revokeTokenById(string $id): JsonResponse
    {
        $token = DB::transaction(function () use ($id) {
            return QrToken::where('id', $id)
                ->lockForUpdate()
                ->first();
        });

        if (!$token) {
            return response()->json(responseFormatter(constant: DEFAULT_404), 404);
        }

        $token->update(['is_revoked' => true]);

        return response()->json(responseFormatter(DEFAULT_200));
    }

    public function referralCount(Request $request): JsonResponse
    {
        $count = QrToken::where('created_by', $request->user()->id)
            ->whereNotNull('redeemed_at')
            ->count();

        return response()->json(responseFormatter(DEFAULT_200, ['count' => $count]));
    }
}
