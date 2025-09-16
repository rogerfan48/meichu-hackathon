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

private const val EXTRA_DRAWABLE_RESOURCES = "android.view.accessibility.extra.DRAWABLE_RESOURCES"

class ScreenReader: AccessibilityService() { // 無障礙服務開啟後的廣播 用來告訴 MainActivity 無障礙服務已啟動要開啟app
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("ScreenReaderService", "Accessibility Service Connected")
        val intent = Intent("com.example.foodie.ACCESSIBILITY_ENABLED")
        intent.setPackage(packageName)
        sendBroadcast(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) { // 接收無障礙模式事件
        val rootNode = event?.source
        if (rootNode != null) {
            organizeUITree(rootNode)
            //printNodeTree(rootNode)
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