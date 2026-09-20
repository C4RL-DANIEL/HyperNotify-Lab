package com.hypernotify.lab;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import androidx.annotation.Nullable;

/**
 * HyperNotify Lab - Android 16 Live Update foreground service.
 *
 * On Android 16 (API 36) a standard ongoing notification built with
 * {@link Notification.ProgressStyle} is automatically promoted by the system
 * to a "Live Update" status-bar chip. On Xiaomi HyperOS, the system compositor
 * intercepts these Android 16 Live Update notifications and projects them into
 * the Hyper Island capsule.
 *
 * This is the official, supported mechanism - no system API or custom island
 * intent is required. The system decides the presentation via the standard
 * notification APIs below.
 */
public class LiveUpdateService extends Service {

    public static final String CHANNEL_ID = "live_update_channel";
    public static final int NOTIFICATION_ID = 1001;

    private NotificationManager notificationManager;
    private Handler handler;
    private int currentProgress = 0;
    private final int MAX_PROGRESS = 100;
    private Runnable updateRunnable;

    @Override
    public void onCreate() {
        super.onCreate();
        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        handler = new Handler(Looper.getMainLooper());
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Start as foreground service to keep the live-update stream alive.
        Notification initialNotification = buildLiveUpdateNotification(0, "Starting activity...");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, initialNotification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE);
        } else {
            startForeground(NOTIFICATION_ID, initialNotification);
        }

        startProgressSimulation();
        return START_STICKY;
    }

    /** Stop the live update if it is running. */
    public static void stopUpdate(Context context) {
        context.stopService(new Intent(context, LiveUpdateService.class));
    }

    /** Start the live update (called from the UI). */
    public static void startUpdate(Context context) {
        context.startForegroundService(new Intent(context, LiveUpdateService.class));
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Live Updates",
                    NotificationManager.IMPORTANCE_HIGH);
            channel.setDescription("Real-time status bar / Hyper Island live updates.");
            channel.setShowBadge(true);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private Notification buildLiveUpdateNotification(int progress, String statusMessage) {
        Intent tapIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, tapIntent, PendingIntent.FLAG_IMMUTABLE);

        Notification.Builder builder;

        if (Build.VERSION.SDK_INT >= 36) {
            // Android 16+ native Live Update promotion path.
            builder = new Notification.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_stat_island)
                    .setContentTitle("Live Activity")
                    .setContentText(statusMessage)
                    .setOngoing(true)
                    .setContentIntent(pendingIntent)
                    .setCategory(Notification.CATEGORY_PROGRESS);

            // ProgressStyle triggers the Android 16 Live Update status-bar chip.
            Notification.ProgressStyle progressStyle = new Notification.ProgressStyle()
                    .setProgress(progress)
                    .setMaxProgress(MAX_PROGRESS)
                    .setShortCriticalText(progress + "%"); // rendered inside the island chip
            builder.setStyle(progressStyle);
        } else {
            // Fallback for Android 10-15 / direct HyperOS projection.
            builder = new Notification.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_stat_island)
                    .setContentTitle("Live Activity")
                    .setContentText(statusMessage)
                    .setOngoing(true)
                    .setContentIntent(pendingIntent)
                    .setProgress(MAX_PROGRESS, progress, false);
        }

        return builder.build();
    }

    private void startProgressSimulation() {
        updateRunnable = new Runnable() {
            @Override
            public void run() {
                if (currentProgress <= MAX_PROGRESS) {
                    String text = "Processing: " + currentProgress + "%";
                    Notification updated = buildLiveUpdateNotification(currentProgress, text);
                    notificationManager.notify(NOTIFICATION_ID, updated);
                    currentProgress += 5;
                    handler.postDelayed(this, 1000);
                } else {
                    stopSelf();
                }
            }
        };
        handler.post(updateRunnable);
    }

    @Override
    public void onDestroy() {
        if (handler != null && updateRunnable != null) {
            handler.removeCallbacks(updateRunnable);
        }
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}