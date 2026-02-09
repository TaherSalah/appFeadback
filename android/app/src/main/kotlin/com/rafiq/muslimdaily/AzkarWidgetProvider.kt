package com.rafiq.muslimdaily

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.content.Intent

class AzkarWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.azkar_widget_layout)

            // Get Azkar data from shared preferences
            val azkarText = widgetData.getString("azkar_text", "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ")
            val azkarCount = widgetData.getString("azkar_count", "33")
            val azkarTitle = widgetData.getString("azkar_title", "أذكار اليوم")

            views.setTextViewText(R.id.widget_azkar_text, azkarText)
            views.setTextViewText(R.id.widget_azkar_count, azkarCount)
            views.setTextViewText(R.id.widget_azkar_title, azkarTitle)

            // Set click intent to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_screen", "azkar")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_azkar_text, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
