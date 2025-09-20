package com.example.foodie

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import android.os.Build
import android.util.Log
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.WindowManager
import android.view.View
import android.view.GestureDetector
import android.view.MotionEvent
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.GestureDetector.SimpleOnGestureListener
import android.view.KeyEvent

class ScreenReader: AccessibilityService() { 

    data class NodeSet( // 用來分類 UI 樹的資料結構
        val texts: MutableList<AccessibilityNodeInfo> = mutableListOf(),
        val images: MutableList<AccessibilityNodeInfo> = mutableListOf(),
        val tools: MutableList<AccessibilityNodeInfo> = mutableListOf()
    )
    val nodeSet = NodeSet()

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var gestureDetector: GestureDetector? = null

    private val gestureListener = object : SimpleOnGestureListener() {
        override fun onLongPress(e: MotionEvent) {
            val x = e.rawX.toInt()
            val y = e.rawY.toInt()
            Log.d("ScreenReaderService", "Long press detected at screen coordinates: x=$x, y=$y")
            findNodebyOffset(x, y)?.let { node ->

                Log.d("ScreenReaderService", "Node found at long press location: class=${node.className} text=${node.text} desc=${node.contentDescription} clickable=${node.isClickable}")
            }
            // 在這裡你可以使用 x 和 y 座標進行後續操作
        }
        override fun onSingleTapUp(e: MotionEvent): Boolean {
            Log.d("ScreenReaderService", "Press detected")
            val x = e.rawX.toInt()
            val y = e.rawY.toInt()
            findNodebyOffset(x, y)?.let { node ->
                if (node.isClickable) {
                    Log.d("ScreenReaderService", "Clickable node tapped: class=${node.className} text=${node.text} desc=${node.contentDescription}")
                    node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                }
            }
            return true
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Get the existing service info
        val info = serviceInfo
        // Set the event types you want to receive
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                          AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED

        info.flags = AccessibilityServiceInfo.FLAG_REQUEST_FILTER_KEY_EVENTS
        
        // Apply the new configuration
        this.serviceInfo = info

        // ----懸浮視窗-----
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        overlayView = View(this)
        
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSPARENT
        )
        layoutParams.gravity = Gravity.TOP or Gravity.LEFT

        gestureDetector = GestureDetector(this, gestureListener)
        overlayView?.setOnTouchListener { _, event ->
            gestureDetector?.onTouchEvent(event)
            false
        }

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            Log.e("ScreenReaderService", "Failed to add overlay view", e)
        }
        // ----懸浮視窗-----

        Log.d("ScreenReaderService", "Accessibility Service Connected")
        val intent = Intent("com.example.foodie.ACCESSIBILITY_ENABLED")
        intent.setPackage(packageName)
        sendBroadcast(intent)
    }

    override fun onUnbind(intent: Intent?): Boolean { // 無障礙服務關閉後的廣播 用來告訴 MainActivity 無障礙服務已關閉要關閉app
        Log.d("ScreenReaderService", "Accessibility Service Disconnected")
        if (overlayView != null && windowManager != null) {
            windowManager?.removeView(overlayView)
            overlayView = null
        }
        val intent = Intent("com.example.foodie.ACCESSIBILITY_DISABLED")
        intent.setPackage(packageName)
        sendBroadcast(intent)
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val sourceNode = event.source
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {  
                if (sourceNode != null) {
                    organizeUITree(sourceNode)
                    //printNodeTree(sourceNode)
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

    private fun decodeTree(node: AccessibilityNodeInfo?, nodeSet: NodeSet) { //把 UI 樹分類成 text, image, tool 三個陣列，刪掉沒有文字或圖片資訊的 node
        if (node == null) return
        if(node.text != null || node.contentDescription != null || node.className == "android.widget.ImageView") {
            if (node.className == "android.widget.TextView")
                nodeSet.texts.add(node)
            else if (node.className == "android.widget.ImageView")
                nodeSet.images.add(node)
            else
                if(node.className != "android.widget.FrameLayout" && node.className != "android.widget.LinearLayout" && node.className != "android.widget.RelativeLayout" && node.className != "android.view.ViewGroup")
                nodeSet.tools.add(node)
        }
        for (i in 0 until node.childCount) { 
            decodeTree(node.getChild(i), nodeSet)
        }
    }

    private fun organizeUITree(node: AccessibilityNodeInfo?) {
        
        decodeTree(node, nodeSet)
        // if (nodeSet.texts.isEmpty() && nodeSet.images.isEmpty() && nodeSet.tools.isEmpty()) return
        // for( textNode in nodeSet.texts) {
        //     val rect = android.graphics.Rect()
        //     textNode.getBoundsInScreen(rect)
        //     // Log.d("ScreenReaderService", "Text Node: ${textNode.text} | containsImg: ${textNode.contentDescription != null} | bounds: $rect")
        // }
        // for( imageNode in nodeSet.images) {
        //     val rect = android.graphics.Rect()
        //     imageNode.getBoundsInScreen(rect)
        //     // Log.d("ScreenReaderService", "Image Node: ${imageNode.contentDescription ?: "No description"} | bounds: $rect")
        // }
        // for( toolNode in nodeSet.tools) {
        //     val rect = android.graphics.Rect()
        //     toolNode.getBoundsInScreen(rect)
        //     // Log.d("ScreenReaderService", "Tool Node: ${toolNode.className} | text: ${toolNode.text ?: "No text"} | desc: ${toolNode.contentDescription ?: "No description"} | bounds: $rect")
        // }
    }

    private fun findNodebyOffset(x: Int, y: Int): AccessibilityNodeInfo? { // 根據座標找 node

        val rootNode = rootInActiveWindow ?: return null
        val currentNodes = NodeSet()
        decodeTree(rootNode, currentNodes)

        for (node in currentNodes.texts + currentNodes.images + currentNodes.tools) {
            val rect = android.graphics.Rect()
            node.getBoundsInScreen(rect)
            if (rect.contains(x, y)) {
                return node
            }
        }
        return null
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        Log.d("ScreenReaderService", "Key event: keyCode=${event.keyCode} action=${event.action}")
        if (event.action == KeyEvent.ACTION_DOWN) { // 只在按下時觸發
            when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    Log.d("ScreenReaderService", "Volume Up key pressed")
                    // 在這裡處理音量增加的邏輯
                    setOverlayVisible(true)
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    Log.d("ScreenReaderService", "Volume Down key pressed")
                    // 在這裡處理音量減少的邏輯
                    setOverlayVisible(false)
                }
            }
        }
        // 回傳 super.onKeyEvent(event) 可以讓系統繼續處理預設行為 (調整音量)
        return super.onKeyEvent(event)
    }

    fun setOverlayVisible(isVisible: Boolean) {
        if (isVisible) {
            if (overlayView == null && windowManager != null) {
                overlayView = View(this)
                val layoutParams = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                    PixelFormat.TRANSPARENT
                )
                layoutParams.gravity = Gravity.TOP or Gravity.LEFT

                gestureDetector = GestureDetector(this, gestureListener)
                overlayView?.setOnTouchListener { _, event ->
                    gestureDetector?.onTouchEvent(event)
                    false
                }

                try {
                    windowManager?.addView(overlayView, layoutParams)
                    Log.d("ScreenReaderService", "Overlay added")
                } catch (e: Exception) {
                    Log.e("ScreenReaderService", "Failed to add overlay view", e)
                }
            }
        } else {
            if (overlayView != null && windowManager != null) {
                try {
                    windowManager?.removeView(overlayView)
                    overlayView = null
                    Log.d("ScreenReaderService", "Overlay removed")
                } catch (e: Exception) {
                    Log.e("ScreenReaderService", "Failed to remove overlay view", e)
                }
            }
        }
    }
}