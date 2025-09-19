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
                jumpToAccessibilitySetting()
                result.success(true)
            } else if (call.method == "stopProjection") {
                jumpToAccessibilitySetting()
                result.success(true)
            } else if (call.method == "isScreenReaderEnabled") {
                result.success(isScreenReaderEnabled())
            } else if (call.method == "isTalkBackEnabled") {
                result.success(isTalkBackEnabled())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isScreenReaderEnabled(): Boolean { // 檢查無障礙服務是否啟動
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

    private fun isTalkBackEnabled(): Boolean { // 檢查TalkBack是否啟動
        val talkBackService = "com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService"
        try {
            val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            val colonSplitter = TextUtils.SimpleStringSplitter(':')
            if (enabledServices != null) {
                colonSplitter.setString(enabledServices)
                while (colonSplitter.hasNext()) {
                    val componentName = colonSplitter.next()
                    if (componentName.equals(talkBackService, ignoreCase = true)) {
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error checking TalkBack service", e)
        }
        return false
    }

    override fun onCreate(savedInstanceState: Bundle?) { // 接收無障礙服務啟動的廣播 用來自動開啟 app
        super.onCreate(savedInstanceState)
        val enabledFilter = IntentFilter("com.example.foodie.ACCESSIBILITY_ENABLED")
        registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                runTheApp()
            }
        }, enabledFilter, RECEIVER_EXPORTED)

        val disabledFilter = IntentFilter("com.example.foodie.ACCESSIBILITY_DISABLED")
        registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d("MainActivity", "Accessibility Service Disabled. Finishing activity.")
                runTheApp()
            }
        }, disabledFilter, RECEIVER_EXPORTED)
    }

    private fun jumpToAccessibilitySetting() {
        // Implement your screen capture logic here
        Log.d("MainActivity", "Jump to Accessibility Setting")
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun runTheApp() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(launchIntent)
    }
}
