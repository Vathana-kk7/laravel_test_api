<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        // Tell Laravel to use custom URL instead of password.reset route
        ResetPassword::createUrlUsing(function ($user, string $token) {
            // use the application URL and point to the front‑end reset path
            // (the client is expected to POST to /api/reset-password with the
            // token once the user submits a new password)
            $appUrl = config('app.url') ?: 'http://localhost:8000';
            return $appUrl . '/reset-password?token=' . $token . '&email=' . urlencode($user->email);
        });
    }
}
