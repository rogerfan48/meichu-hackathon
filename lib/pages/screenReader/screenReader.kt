package com.example.foodie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.util.Log

class ScreenReader: AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val rootNode = event?.source
        if (rootNode != null) {
            Log.d("ScreenReaderService", "Root Node: ${rootNode.className}")
            traverse(rootNode)
        }
    }

    override fun onInterrupt() {
        Log.d("ScreenReaderService", "Service Interrupted")
    }

    private fun traverse(node: AccessibilityNodeInfo?) {
        if(node == null) return;
        Log.d("ScreenReaderService", "Node: ${node.className}, Text: ${node.text}")
        for(i in 0 until node.childCount) {
            traverse(node.getChild(i))
        }
    }
}