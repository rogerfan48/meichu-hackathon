package com.example.foodie

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.os.Build
import android.util.Log

private const val EXTRA_DRAWABLE_RESOURCES = "android.view.accessibility.extra.DRAWABLE_RESOURCES"

class ScreenReader: AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val rootNode = event?.source
        if (rootNode != null) {
            organizeUITree(rootNode)
            //printNodeTree(rootNode)
        }
    }

    override fun onInterrupt() {
        Log.d("ScreenReaderService", "Service Interrupted")
    }

    private fun printNodeTree(node: AccessibilityNodeInfo?, indent: String = "") {
        if (node == null) return
        Log.d("ScreenReaderService", "$indent- ${node.className} | text: ${node.text} | contentDesc: ${node.contentDescription}")
        for (i in 0 until node.childCount) {
            printNodeTree(node.getChild(i), indent + "  ")
        }
    }

    data class NodeSet(
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