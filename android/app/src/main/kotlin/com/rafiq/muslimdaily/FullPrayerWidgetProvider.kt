package com.rafiq.muslimdaily

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.os.SystemClock
import es.antonborri.home_widget.HomeWidgetPlugin

class FullPrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.full_prayer_widget_layout)

            // Get all prayer times from shared preferences
            val fajrTime = widgetData.getString("fajr_time", "4:45") ?: "4:45"
            val sunriseTime = widgetData.getString("sunrise_time", "6:12") ?: "6:12"
            val dhuhrTime = widgetData.getString("dhuhr_time", "12:15") ?: "12:15"
            val asrTime = widgetData.getString("asr_time", "3:30") ?: "3:30"
            val maghribTime = widgetData.getString("maghrib_time", "5:45") ?: "5:45"
            val ishaTime = widgetData.getString("isha_time", "7:05") ?: "7:05"
            val nextPrayer = widgetData.getString("next_prayer", "العصر") ?: "العصر"
            val city = widgetData.getString("city", "القاهرة") ?: "القاهرة"
            
            // Get next prayer time in milliseconds for Chronometer
            val nextPrayerMillis = widgetData.getLong("next_prayer_time_millis", 0L)

            // Update all prayer texts
            views.setTextViewText(R.id.widget_fajr_time, fajrTime)
            views.setTextViewText(R.id.widget_sunrise_time, sunriseTime)
            views.setTextViewText(R.id.widget_dhuhr_time, dhuhrTime)
            views.setTextViewText(R.id.widget_asr_time, asrTime)
            views.setTextViewText(R.id.widget_maghrib_time, maghribTime)
            views.setTextViewText(R.id.widget_isha_time, ishaTime)
            views.setTextViewText(R.id.widget_next_prayer_name, nextPrayer)
            views.setTextViewText(R.id.widget_full_city, city)
            
            // Setup Chronometer
            if (nextPrayerMillis > 0) {
                // Calculate time difference
                val now = System.currentTimeMillis()
                // Ensure the time is in the future
                if (nextPrayerMillis > now) {
                    views.setChronometerCountDown(R.id.prayer_chronometer, true)
                    views.setChronometer(R.id.prayer_chronometer, SystemClock.elapsedRealtime() + (nextPrayerMillis - now), null, true)
                } else {
                    views.setTextViewText(R.id.prayer_chronometer, "00:00")
                }
            } else {
                 views.setTextViewText(R.id.prayer_chronometer, "--:--")
            }

            // Highlight the next prayer
            resetBackgrounds(views)
            highlightNextPrayer(views, nextPrayer)
            
            // Set click intent to open app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context, 
                    0, 
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun resetBackgrounds(views: RemoteViews) {
        views.setInt(R.id.fajr_container, "setBackgroundResource", R.drawable.glass_item_background)
        views.setInt(R.id.sunrise_container, "setBackgroundResource", R.drawable.glass_item_background)
        views.setInt(R.id.dhuhr_container, "setBackgroundResource", R.drawable.glass_item_background)
        views.setInt(R.id.asr_container, "setBackgroundResource", R.drawable.glass_item_background)
        views.setInt(R.id.maghrib_container, "setBackgroundResource", R.drawable.glass_item_background)
        views.setInt(R.id.isha_container, "setBackgroundResource", R.drawable.glass_item_background)
    }

    private fun highlightNextPrayer(views: RemoteViews, nextPrayer: String) {
        when {
            nextPrayer.contains("الفجر") -> views.setInt(R.id.fajr_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
            nextPrayer.contains("الشروق") -> views.setInt(R.id.sunrise_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
            nextPrayer.contains("الظهر") || nextPrayer.contains("الجمعة") -> views.setInt(R.id.dhuhr_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
            nextPrayer.contains("العصر") -> views.setInt(R.id.asr_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
            nextPrayer.contains("المغرب") -> views.setInt(R.id.maghrib_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
            nextPrayer.contains("العشاء") -> views.setInt(R.id.isha_container, "setBackgroundResource", R.drawable.glass_item_highlighted)
        }
    }
}
