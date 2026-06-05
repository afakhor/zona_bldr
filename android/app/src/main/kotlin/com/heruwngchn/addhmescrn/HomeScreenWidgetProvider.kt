package com.heruwngchn.addhmescrn

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // 1. Ambil data nama dari Flutter, kalau kosong pakai text default
            val namaMurid = widgetData.getString("key_nama", "Coach Menu Active")
            views.setTextViewText(R.id.tv_nama_murid, namaMurid)

            // 2. Ambil data status dari Flutter, kalau kosong pakai text default
            val statusData = widgetData.getString("key_status", "Sistem Siap Tempur")
            views.setTextViewText(R.id.tv_status_data, statusData)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
