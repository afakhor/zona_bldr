package com.heruwngchn.addhmescrn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.heruwngchn.addhmescrn.R

class HomeScreenWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Mengambil data dari SharedPreferences lokal yang dilempar Flutter
        val widgetData: SharedPreferences = context.getSharedPreferences(
            "FlutterSharedPreferences", 
            Context.MODE_PRIVATE
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Mengambil string dengan kunci dari Flutter (menggunakan prefix bawaan shared_preferences)
            // Di Flutter, shared_preferences otomatis menambah awalan 'flutter.' di memorinya
            val namaMurid = widgetData.getString("flutter.saved_nama", "Coach Menu Active")
            val statusData = widgetData.getString("flutter.saved_status", "Sistem Siap Tempur")

            views.setTextViewText(R.id.tv_nama_murid, namaMurid)
            views.setTextViewText(R.id.tv_status_data, statusData)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
