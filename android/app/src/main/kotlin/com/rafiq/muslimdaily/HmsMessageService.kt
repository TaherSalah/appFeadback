package com.rafiq.muslimdaily

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.NotificationCompat
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage

/**
 * Huawei Push Message Service
 *
 * مسجّل في AndroidManifest.xml كـ Service.
 *
 * ### المسؤوليات:
 * - استلام HMS Token الجديد وإرساله لـ Flutter عبر:
 *   1. [HuaweiPush.onNewToken] (الطريقة الرسمية للـ plugin)
 *   2. [MuslimDailyApplication.hmsTokenEventSink] (EventChannel المخصص)
 * - معالجة الرسائل في Background/Terminated
 * - عرض Local Notifications للرسائل من نوع Data-Only
 */
class HmsMessageService : HmsMessageService() {

    companion object {
        private const val TAG = "[HMS-PUSH]"
        private const val CHANNEL_ID = "hms_push_channel"
        private const val CHANNEL_NAME = "إشعارات هواوي"
    }

    /**
     * يُستدعى عند استلام HMS Token جديد أو تجديده
     */
    override fun onNewToken(token: String?, bundle: Bundle?) {
        super.onNewToken(token, bundle)

        if (token.isNullOrEmpty()) {
            Log.w(TAG, "onNewToken: received null/empty token")
            return
        }

        Log.i(TAG, "✅ HMS Token received (length: ${token.length})")

        // ① تم إزالة استدعاء HuaweiPush لأنه غير متوفر في هذه النسخة من الإضافة

        // ② إرسال عبر EventChannel المخصص → يصل لـ Flutter مباشرة
        try {
            MuslimDailyApplication.hmsTokenEventSink?.success(token)
            Log.d(TAG, "Token sent via custom EventChannel")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send token via EventChannel: ${e.message}")
        }
    }

    /**
     * يُستدعى عند استلام رسالة في:
     * - الـ Foreground (جميع الأنواع)
     * - الـ Background (Data-Only messages فقط)
     */
    override fun onMessageReceived(message: RemoteMessage?) {
        super.onMessageReceived(message)

        if (message == null) return

        Log.i(TAG, "📩 HMS Message received: id=${message.messageId}")

        // إرسال الرسالة للـ Flutter سيتم معالجته إن أمكن أو نكتفي بالإشعار المحلي

        // إذا كانت Data-Only → نعرضها كـ Local Notification يدوياً
        val hasNotificationPayload = message.notification?.title?.isNotEmpty() == true
        if (!hasNotificationPayload && message.dataOfMap.isNotEmpty()) {
            Log.d(TAG, "Data-only message → showing local notification manually")
            showDataNotification(message)
        }
    }

    override fun onMessageSent(msgId: String?) {
        super.onMessageSent(msgId)
        Log.d(TAG, "Message sent: $msgId")
    }

    override fun onSendError(msgId: String?, exception: Exception?) {
        super.onSendError(msgId, exception)
        Log.e(TAG, "Message send error: $msgId → ${exception?.message}")
    }

    // ─────────────────────────────────────────────────────────────────
    //  Local Notification للـ Data-Only Messages
    // ─────────────────────────────────────────────────────────────────

    private fun showDataNotification(message: RemoteMessage) {
        try {
            createNotificationChannelIfNeeded()

            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                message.dataOfMap.forEach { (key, value) -> putExtra(key, value) }
                putExtra("from_hms", true)
                putExtra("message_id", message.messageId)
            }

            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_ONE_SHOT
            }

            val pendingIntent = PendingIntent.getActivity(
                this,
                System.currentTimeMillis().toInt(),
                intent,
                pendingIntentFlags
            )

            val title = message.dataOfMap["title"]
                ?: message.dataOfMap["alert_title"]
                ?: "رفيق المسلم"
            val body = message.dataOfMap["body"]
                ?: message.dataOfMap["alert_body"]
                ?: ""

            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_notify)
                .setContentTitle(title)
                .setContentText(body)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setContentIntent(pendingIntent)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .build()

            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(System.currentTimeMillis().toInt(), notification)

            Log.d(TAG, "Local notification shown for data-only HMS message")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show HMS data notification: ${e.message}")
        }
    }

    private fun createNotificationChannelIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "إشعارات تطبيق رفيق المسلم"
                    enableLights(true)
                    enableVibration(true)
                }
                nm.createNotificationChannel(channel)
            }
        }
    }
}
