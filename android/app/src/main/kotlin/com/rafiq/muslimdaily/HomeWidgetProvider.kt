package com.rafiq.muslimdaily

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.content.Intent

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val prayerName = widgetData.getString("prayer_name", "--")
            val prayerTime = widgetData.getString("prayer_time", "--:--")
            val city = widgetData.getString("city", "--")
            val hijriDate = widgetData.getString("hijri_date", "")
            val nextPrayerMillis = widgetData.getLong("next_prayer_time_millis", 0L)

            views.setTextViewText(R.id.widget_prayer_name, prayerName)
            views.setTextViewText(R.id.widget_prayer_time, prayerTime)
            views.setTextViewText(R.id.widget_city, city)
            views.setTextViewText(R.id.widget_hijri_date, hijriDate)

            // Setup Chronometer for time left
            if (nextPrayerMillis > 0) {
                val now = System.currentTimeMillis()
                if (nextPrayerMillis > now) {
                    views.setChronometerCountDown(R.id.widget_time_left_chronometer, true)
                    views.setChronometer(
                        R.id.widget_time_left_chronometer,
                        android.os.SystemClock.elapsedRealtime() + (nextPrayerMillis - now),
                        null,
                        true
                    )
                } else {
                    views.setTextViewText(R.id.widget_time_left_chronometer, "00:00")
                }
            } else {
                 views.setTextViewText(R.id.widget_time_left_chronometer, "--:--")
            }

            // Set click intent to open Prayer Times in app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_screen", "prayer_times")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_prayer_time, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

