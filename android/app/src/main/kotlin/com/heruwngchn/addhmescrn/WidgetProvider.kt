package com.heruwngchn.addhmescreen// Ganti sesuai package kamu

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // Ambil data dari Flutter via home_widget
                val title = widgetData.getString("title", "Zona Beladiri")
                val message = widgetData.getString("message", "Tap untuk buka app")
                
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_message, message)

                // Biar bisa klik widget -> buka app
                val pendingIntent = getFlutterAppPendingIntent(context)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}