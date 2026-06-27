package com.rafiq.muslimdaily

import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : AudioServiceActivity() {

    companion object {
        /**
         * اسم EventChannel يجب أن يطابق الاسم في hms_push_provider.dart
         */
        private const val HMS_TOKEN_CHANNEL = "com.rafiq.muslimdaily/hms_token_events"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ✅ تسجيل Push Detector Plugin (يكتشف GMS أو HMS)
        PushDetectorPlugin.registerWith(flutterEngine, applicationContext)

        // ✅ تسجيل EventChannel لاستقبال HMS Token في Flutter
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HMS_TOKEN_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // تخزين الـ EventSink في Application class
                // لكي يصل إليه HmsMessageService عند استلام Token جديد
                MuslimDailyApplication.hmsTokenEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                MuslimDailyApplication.hmsTokenEventSink = null
            }
        })
    }
}
