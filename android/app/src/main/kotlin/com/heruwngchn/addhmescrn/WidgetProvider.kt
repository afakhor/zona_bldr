package com.heruwngchn.addhmescrn

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class WidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // Ambil path gambar dari Flutter
                val imagePath = widgetData.getString("img_path", null)
                val namaAtlet = widgetData.getString("nama_atlet", "Zona Beladiri")
                
                if (imagePath != null && File(imagePath).exists()) {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    setImageViewBitmap(R.id.widget_image, bitmap)
                    setViewVisibility(R.id.widget_image, android.view.View.VISIBLE)
                    setViewVisibility(R.id.widget_placeholder, android.view.View.GONE)
                } else {
                    setViewVisibility(R.id.widget_image, android.view.View.GONE)
                    setViewVisibility(R.id.widget_placeholder, android.view.View.VISIBLE)
                }

                setTextViewText(R.id.widget_nama, namaAtlet)

                // Klik widget -> buka app
                val pendingIntent = getFlutterAppPendingIntent(context)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}