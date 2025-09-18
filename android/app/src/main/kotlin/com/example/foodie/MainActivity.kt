package com.example.foodie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.content.Context
import android.content.Intent
import android.text.TextUtils
import android.util.Log
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.screen_reader/projection" // Channel name

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) { // Flutter 與原生的溝通橋樑
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startProjection") {
                if (!isAccessibilityServiceEnabled()) {
                    Log.d("MainActivity", "Accessibility Service not enabled. Opening settings.")
                    startScreenCaptureIntent()
                } else {
                    Log.d("MainActivity", "Accessibility Service is already enabled.")
                    runTheApp()
                }
                result.success(true)
            } else if (call.method == "stopProjection") {
                if (isAccessibilityServiceEnabled()) {
                    stopScreenCaptureIntent()
                }
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean { // 檢查無障礙服務是否啟動
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

    override fun onCreate(savedInstanceState: Bundle?) { // 接收無障礙服務啟動的廣播 用來開啟 app
        super.onCreate(savedInstanceState)
        val filter = IntentFilter("com.example.foodie.ACCESSIBILITY_ENABLED")
        registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                runTheApp()
            }
        }, filter, RECEIVER_EXPORTED)
    }

    private fun startScreenCaptureIntent() {
        // Implement your screen capture logic here
        Log.d("MainActivity", "Screen capture intent started")
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun stopScreenCaptureIntent() {
        // Implement your screen capture logic here
        Log.d("MainActivity", "Screen capture intent stopped")
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun runTheApp() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(launchIntent)
    }
}
