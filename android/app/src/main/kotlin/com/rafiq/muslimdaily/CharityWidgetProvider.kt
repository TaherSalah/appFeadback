package com.rafiq.muslimdaily

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.content.Intent

class CharityWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.charity_widget_layout)

            // Get Charity data from shared preferences
            val charityAmount = widgetData.getString("charity_amount", "0")
            val charityCurrency = widgetData.getString("charity_currency", " ج.م")
            val charityStreak = widgetData.getString("charity_streak", "0")
            val charityTitle = widgetData.getString("charity_title", "صدقاتي هذا الشهر")

            views.setTextViewText(R.id.widget_charity_amount, charityAmount)
            views.setTextViewText(R.id.widget_charity_currency, charityCurrency)
            views.setTextViewText(R.id.widget_charity_streak, charityStreak)
            views.setTextViewText(R.id.widget_charity_title, charityTitle)

            // Set click intent to open Charity screen in app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_screen", "charity")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                2,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_charity_amount, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
