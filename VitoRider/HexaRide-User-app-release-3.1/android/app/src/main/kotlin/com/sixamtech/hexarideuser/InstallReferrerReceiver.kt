package com.sixamtech.hexarideuser

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri

class InstallReferrerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "com.android.vending.INSTALL_REFERRER") return
        val referrer = intent.getStringExtra("referrer") ?: return
        try {
            val decoded = Uri.decode(referrer)
            val params = decoded.split("&").associate {
                val (k, v) = it.split("=", limit = 2)
                k to v
            }
            val token = params["token"] ?: return
            if (token.length == 64 && token.matches(Regex("[A-Za-z0-9]{64}"))) {
                val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                prefs.edit().putString("flutter.install_referrer_token", token).apply()
            }
        } catch (_: Exception) {}
    }
}
