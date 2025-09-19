package com.example.foodie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import android.os.Bundle
import android.os.Build
import android.util.Log
import android.accessibilityservice.AccessibilityServiceInfo

private const val EXTRA_DRAWABLE_RESOURCES = "android.view.accessibility.extra.DRAWABLE_RESOURCES"

class ScreenReader: AccessibilityService() { 
    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = serviceInfo
        info.eventTypes =
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
            AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED
        info.notificationTimeout = 50
        this.serviceInfo = info
        Log.d("ScreenReaderService", "Accessibility Service Connected (reconfigured)")
        val intent = Intent("com.example.foodie.ACCESSIBILITY_ENABLED")
        intent.setPackage(packageName)
        sendBroadcast(intent)
    }

    override fun onUnbind(intent: Intent?): Boolean { // 無障礙服務關閉後的廣播 用來告訴 MainActivity 無障礙服務已關閉要關閉app
        Log.d("ScreenReaderService", "Accessibility Service Disconnected")
        val intent = Intent("com.example.foodie.ACCESSIBILITY_DISABLED")
        intent.setPackage(packageName)
        sendBroadcast(intent)
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        Log.d(
            "ScreenReaderService",
            "Event type=${event.eventType} class=${event.className} text=${event.text} contentDesc=${event.contentDescription}"
        )
        val sourceNode = event.source
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                if (sourceNode != null) {
                    organizeUITree(sourceNode)
                }
            }
            AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED -> {
                if (sourceNode != null) {
                    Log.d("ScreenReaderService", "Focused node: ${sourceNode.text ?: sourceNode.contentDescription}")
                }
            }
        }
        
    }

    override fun onInterrupt() {
        Log.d("ScreenReaderService", "Service Interrupted")
    }

    private fun printNodeTree(node: AccessibilityNodeInfo?, indent: String = "") { // 印出整棵 UI 樹，方便 debug
        if (node == null) return
        Log.d("ScreenReaderService", "$indent- ${node.className} | text: ${node.text} | contentDesc: ${node.contentDescription}")
        for (i in 0 until node.childCount) {
            printNodeTree(node.getChild(i), indent + "  ")
        }
    }

    data class NodeSet( // 用來分類 UI 樹的資料結構
        val texts: MutableList<AccessibilityNodeInfo> = mutableListOf(),
        val images: MutableList<AccessibilityNodeInfo> = mutableListOf(),
        val tools: MutableList<AccessibilityNodeInfo> = mutableListOf()
    )

    private fun decodeTree(node: AccessibilityNodeInfo?, nodeSet: NodeSet) { //把 UI 樹分類成 text, image, tool 三個陣列，刪掉沒有文字或圖片資訊的 node
        if (node == null) return
        if(node.text != null || node.contentDescription != null || node.className == "android.widget.ImageView") {
            if (node.className == "android.widget.TextView")
                nodeSet.texts.add(node)
            else if (node.className == "android.widget.ImageView")
                nodeSet.images.add(node)
            else
                nodeSet.tools.add(node)
        }
        for (i in 0 until node.childCount) { 
            decodeTree(node.getChild(i), nodeSet)
        }
    }

    private fun organizeUITree(node: AccessibilityNodeInfo?) {
        val nodeSet = NodeSet()
        decodeTree(node, nodeSet)
        if (nodeSet.texts.isEmpty() && nodeSet.images.isEmpty() && nodeSet.tools.isEmpty()) return
        for( textNode in nodeSet.texts) {
            Log.d("ScreenReaderService", "Text Node: ${textNode.text} | containsImg: ${textNode.contentDescription != null}")
        }
        for( imageNode in nodeSet.images) {
            Log.d("ScreenReaderService", "Image Node: ${imageNode.contentDescription ?: "No description"}")
        }
        for( toolNode in nodeSet.tools) {
            Log.d("ScreenReaderService", "Tool Node: ${toolNode.className} | text: ${toolNode.text ?: "No text"} | desc: ${toolNode.contentDescription ?: "No description"}")
        }
    }
}