package com.hypernotify.lab.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.hypernotify.lab.R

class NotificationForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "hypernotify_foreground"
        const val NOTIFICATION_ID = 9999
        const val ACTION_START = "com.hypernotify.lab.START_FOREGROUND"
        const val ACTION_STOP = "com.hypernotify.lab.STOP_FOREGROUND"
        const val ACTION_UPDATE = "com.hypernotify.lab.UPDATE_FOREGROUND"
        private const val TAG = "NotificationForegroundSvc"
    }

    private var notificationManager: NotificationManager? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        Log.d(TAG, "Foreground service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_START
        
        when (action) {
            ACTION_START -> {
                val title = intent.getStringExtra("title") ?: "HyperNotify Lab"
                val body = intent.getStringExtra("body") ?: "Running in background"
                val payload = intent.getStringExtra("payload")
                showNotification(title, body, payload)
                Log.d(TAG, "Foreground service started")
            }
            ACTION_STOP -> {
                stopForeground(true)
                stopSelf()
                Log.d(TAG, "Foreground service stopped")
            }
            ACTION_UPDATE -> {
                val title = intent.getStringExtra("title") ?: "HyperNotify Lab"
                val body = intent.getStringExtra("body") ?: "Running in background"
                val payload = intent.getStringExtra("payload")
                updateNotification(title, body, payload)
                Log.d(TAG, "Foreground service updated")
            }
        }
        
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Ongoing notification for HyperNotify Lab foreground service"
                enableVibration = false
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_SECRET
            }
            notificationManager?.createNotificationChannel(channel)
        }
    }

    private fun showNotification(title: String, body: String, payload: String?) {
        val notification = buildNotification(title, body, payload)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun updateNotification(title: String, body: String, payload: String?) {
        val notification = buildNotification(title, body, payload)
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }

    private fun buildNotification(title: String, body: String, payload: String?): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("payload", payload ?: "")
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val stopIntent = Intent(this, NotificationForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setLargeIcon(
                androidx.core.graphics.drawable.IconCompat.createWithResource(this, R.mipmap.ic_launcher)
                    .toBitmap(this)
            )
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_SECRET)
            .setColor(ContextCompat.getColor(this, R.color.primary))
            .setColorized(true)
            .setShowWhen(false)
            .setUsesChronometer(true)
            .setOnlyAlertOnce(true)
            .addAction(
                NotificationCompat.Action.Builder(
                    R.drawable.ic_stop,
                    "Stop Service",
                    stopPendingIntent
                ).build()
            )
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        notificationManager?.cancel(NOTIFICATION_ID)
        Log.d(TAG, "Foreground service destroyed")
    }
}