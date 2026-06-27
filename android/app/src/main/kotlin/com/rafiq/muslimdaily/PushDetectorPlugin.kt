package com.rafiq.muslimdaily

import android.content.Context
import android.util.Log
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter Plugin لاكتشاف توافر Google Mobile Services وHuawei Mobile Services
 *
 * يتواصل مع Dart عبر MethodChannel باسم:
 * `com.rafiq.muslimdaily/push_detector`
 *
 * ### الـ Methods المتاحة:
 * - `checkGmsAvailability` → Int (0 = متاح)
 * - `checkHmsAvailability` → Int (0 = متاح)
 *
 * ### نتائج checkGmsAvailability:
 * - 0: ConnectionResult.SUCCESS (GMS متاح)
 * - 1: SERVICE_MISSING
 * - 2: SERVICE_VERSION_UPDATE_REQUIRED
 * - 3: SERVICE_DISABLED
 */
class PushDetectorPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "[PUSH-DETECTOR]"
        const val CHANNEL_NAME = "com.rafiq.muslimdaily/push_detector"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME
            )
            channel.setMethodCallHandler(PushDetectorPlugin(context))
            Log.d(TAG, "PushDetectorPlugin registered")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkGmsAvailability" -> handleCheckGms(result)
            "checkHmsAvailability" -> handleCheckHms(result)
            else -> result.notImplemented()
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  GMS Check
    // ─────────────────────────────────────────────────────────────────

    private fun handleCheckGms(result: MethodChannel.Result) {
        try {
            val gmsAvailability = GoogleApiAvailability.getInstance()
            val resultCode = gmsAvailability.isGooglePlayServicesAvailable(context)

            Log.d(TAG, "GMS check result code: $resultCode")

            result.success(resultCode)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking GMS: ${e.message}")
            // إذا فشل الفحص، نُعيد كود خطأ
            result.success(ConnectionResult.API_UNAVAILABLE)
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  HMS Check
    // ─────────────────────────────────────────────────────────────────

    private fun handleCheckHms(result: MethodChannel.Result) {
        try {
            // محاولة تحميل HuaweiApiAvailability بشكل ديناميكي
            // لتجنب الـ ClassNotFoundException على أجهزة GMS
            val hmsAvailabilityClass = Class.forName(
                "com.huawei.hms.api.HuaweiApiAvailability"
            )
            val getInstance = hmsAvailabilityClass.getMethod("getInstance")
            val instance = getInstance.invoke(null)

            val isAvailableMethod = hmsAvailabilityClass.getMethod(
                "isHuaweiMobileServicesAvailable",
                Context::class.java
            )
            val resultCode = isAvailableMethod.invoke(instance, context) as Int

            Log.d(TAG, "HMS check result code: $resultCode")
            result.success(resultCode)

        } catch (e: ClassNotFoundException) {
            // HMS SDK غير مثبّت على هذا الجهاز (جهاز GMS)
            Log.d(TAG, "HMS not available (HMS SDK not found)")
            result.success(1) // SERVICE_MISSING equivalent
        } catch (e: Exception) {
            Log.e(TAG, "Error checking HMS: ${e.message}")
            result.success(1) // افتراض: HMS غير متاح
        }
    }
}
