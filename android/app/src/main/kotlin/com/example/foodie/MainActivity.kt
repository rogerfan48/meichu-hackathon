package com.example.foodie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.os.Bundle
import android.util.Log
import android.text.TextUtils

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.screen_reader/projection" // Channel name

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startProjection") {
                if (!isAccessibilityServiceEnabled()) {
                    Log.d("MainActivity", "Accessibility Service not enabled. Opening settings.")
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                } else {
                    Log.d("MainActivity", "Accessibility Service is already enabled.")
                }
                result.success(true)
            } else if (call.method == "stopProjection") {
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "$packageName/${ScreenReader::class.java.canonicalName}"
        try {
            val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            val colonSplitter = TextUtils.SimpleStringSplitter(':')
            if (enabledServices != null) {
                colonSplitter.setString(enabledServices)
                while (colonSplitter.hasNext()) {
                    val componentName = colonSplitter.next()
                    if (componentName.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error checking accessibility service", e)
        }
        return false
    }

    private fun startScreenCaptureIntent() {
        // Implement your screen capture logic here
        Log.d("MainActivity", "Screen capture intent started")
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
}
