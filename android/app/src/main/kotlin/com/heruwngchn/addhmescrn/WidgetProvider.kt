package com.heruwngchn.addhmescrn

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class WidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
    appWidgetIds.forEach { widgetId ->
        val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
            
            val imagePath = widgetData.getString("img_path", null)
            val namaAtlet = widgetData.getString("nama_atlet", "Zona Beladiri")
            
            if (imagePath != null && File(imagePath).exists()) {
                // Ambil ukuran widget dulu
                val options = appWidgetManager.getAppWidgetOptions(widgetId)
                val maxWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH)
                val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
                
                // Resize bitmap biar nggak overflow
                val bitmap = decodeSampledBitmapFromFile(imagePath, maxWidth, maxHeight)
                setImageViewBitmap(R.id.widget_image, bitmap)
                setViewVisibility(R.id.widget_image, View.VISIBLE)
                setViewVisibility(R.id.widget_placeholder, View.GONE)
            } else {
                setViewVisibility(R.id.widget_image, View.GONE)
                setViewVisibility(R.id.widget_placeholder, View.VISIBLE)
            }

            setTextViewText(R.id.widget_nama, namaAtlet)
            // ... intent biarin
        }
        appWidgetManager.updateAppWidget(widgetId, views)
    }
}

// Tambahin fungsi helper ini di bawah class WidgetProvider
private fun decodeSampledBitmapFromFile(path: String, reqWidth: Int, reqHeight: Int): Bitmap {
    val options = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
    }
    BitmapFactory.decodeFile(path, options)
    
    options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
    options.inJustDecodeBounds = false
    return BitmapFactory.decodeFile(path, options)
}

private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
    val height = options.outHeight
    val width = options.outWidth
    var inSampleSize = 1
    
    if (height > reqHeight || width > reqWidth) {
        val halfHeight = height / 2
        val halfWidth = width / 2
        while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
            inSampleSize *= 2
        }
    }
    return inSampleSize
}
}