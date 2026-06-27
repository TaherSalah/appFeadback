package com.rafiq.muslimdaily

import android.app.Application
import io.flutter.plugin.common.EventChannel

/**
 * تطبيق Android المخصص
 *
 * ### الغرض:
 * تخزين [hmsTokenEventSink] بشكل Static ليمكن الوصول إليه من:
 * - [HmsMessageService]: لإرسال الـ Token عند استقباله
 * - [MainActivity]: لتسجيل الـ EventChannel مع Flutter engine
 *
 * ### التسجيل:
 * يجب إضافة `android:name=".MuslimDailyApplication"` في `<application>` بـ AndroidManifest.xml
 */
class MuslimDailyApplication : Application() {

    companion object {
        /**
         * يُستخدم بـ [HmsMessageService] لإرسال HMS Token لـ Flutter
         * يُسجَّل بـ [MainActivity.configureFlutterEngine] عبر EventChannel
         */
        @Volatile
        var hmsTokenEventSink: EventChannel.EventSink? = null
    }

    override fun onCreate() {
        super.onCreate()
    }
}
