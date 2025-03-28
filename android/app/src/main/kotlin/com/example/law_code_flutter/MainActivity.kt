package com.example.law_code_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.law_code_flutter/sos"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "triggerSos") {
                result.success("SOS triggered from widget")
            } else {
                result.notImplemented()
            }
        }

        if (intent?.action == "SOS_ACTION") {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("sosFromWidget", null)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Безопасно получаем FlutterEngine
        flutterEngine?.let { engine ->
            if (intent.action == "SOS_ACTION") {
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("sosFromWidget", null)
            }
        }
    }
}