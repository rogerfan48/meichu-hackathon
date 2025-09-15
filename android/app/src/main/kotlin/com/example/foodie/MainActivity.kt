package com.example.foodie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.screen_reader/projection" // Channel name

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if(call.method == "startProjection") {
                startScreenCaptureIntent()
                result.success(true)
            } else {
                result.notImplemented()
                Log.d("MainActivity", "gg\n\n\n\n\n\n!!!\n\n\n\n\n\n\n")
            }
        }
    }

    private fun startScreenCaptureIntent() {
        // Implement your screen capture logic here
        Log.d("MainActivity", "Screen capture intent started\n\n\n\n\n\n!!!\n\n\n\n\n\n\n")

    }
}
