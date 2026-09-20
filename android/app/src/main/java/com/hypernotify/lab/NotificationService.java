package com.hypernotify.lab;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;
import android.provider.Settings;

/**
 * HyperNotify Lab - Notification service built on the standard Android 16
 * notification APIs. Channels, actions, priorities and styles are all set
 * correctly so that on Xiaomi/HyperOS the system can promote notifications to
 * the Hyper Island / Super Island pill.
 */
public final class NotificationService {

    // Notification channel IDs
    public static final String CHANNEL_DEFAULT = "hypernotify_default";
    public static final String CHANNEL_HIGH = "hypernotify_high";
    public static final String CHANNEL_CRITICAL = "hypernotify_critical";
    public static final String CHANNEL_ISLAND = "hypernotify_island";

    private static final int[] NOTIFICATION_COLORS = {
        0xFF006EFF, // blue - island/high
        0xFFFF6B00, // orange - default
        0xFF00C853, // green - success
        0xFFFF0000  // red - critical
    };

    private NotificationService() {}

    /**
     * Create all notification channels. Must be called before use, ideally in
     * Application/Launcher. On Android 8+ channels are required; silently
     * ignored on older versions where channelId is unused.
     */
    public static void createChannels(Context context) {
        NotificationManager nm = context.getSystemService(NotificationManager.class);
        if (nm == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel def = new NotificationChannel(
                    CHANNEL_DEFAULT, "Default Notifications", NotificationManager.IMPORTANCE_DEFAULT);
            def.setDescription("Standard HyperNotify Lab notifications");
            def.enableVibration(true);
            def.enableLights(true);
            def.setLightColor(NOTIFICATION_COLORS[0]);
            nm.createNotificationChannel(def);

            NotificationChannel high = new NotificationChannel(
                    CHANNEL_HIGH, "High Priority", NotificationManager.IMPORTANCE_HIGH);
            high.setDescription("High-priority notifications - good for Hyper Island promotion");
            high.enableVibration(true);
            high.setVibrationPattern(new long[]{0, 250, 150, 250});
            high.enableLights(true);
            high.setLightColor(NOTIFICATION_COLORS[1]);
            nm.createNotificationChannel(high);

            NotificationChannel crit = new NotificationChannel(
                    CHANNEL_CRITICAL, "Critical Alerts", NotificationManager.IMPORTANCE_HIGH);
            crit.setDescription("Critical alerts that should interrupt");
            crit.enableVibration(true);
            crit.setVibrationPattern(new long[]{0, 500, 200, 500});
            crit.enableLights(true);
            crit.setLightColor(NOTIFICATION_COLORS[3]);
            crit.setBypassDnd(true);
            crit.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            nm.createNotificationChannel(crit);

            NotificationChannel island = new NotificationChannel(
                    CHANNEL_ISLAND, "Hyper Island", NotificationManager.IMPORTANCE_HIGH);
            island.setDescription("Island-oriented notifications for Xiaomi Hyper Island");
            island.enableVibration(true);
            island.setVibrationPattern(new long[]{0, 250, 150, 250});
            island.enableLights(true);
            island.setLightColor(NOTIFICATION_COLORS[0]);
            island.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            nm.createNotificationChannel(island);
        }
    }

    /** Whether the app currently has notification permission (Android 13+, API 33). */
    public static boolean hasPermission(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
                    == PackageManager.PERMISSION_GRANTED;
        }
        return true; // Pre-13 no runtime permission needed
    }

    /** Whether the primary (default) channel is enabled by the user. */
    public static boolean defaultChannelEnabled(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = context.getSystemService(NotificationManager.class);
            if (nm != null) {
                NotificationChannel ch = nm.getNotificationChannel(CHANNEL_DEFAULT);
                return ch == null || ch.getImportance() != NotificationManager.IMPORTANCE_NONE;
            }
        }
        return true;
    }

    /** Returns the system notification settings Intent (to request permission on 13+). */
    public static Intent permissionIntent(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent i = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
            i.putExtra(Settings.EXTRA_APP_PACKAGE, context.getPackageName());
            return i;
        }
        return new Intent(Settings.ACTION_SETTINGS);
    }

    /** Post a simple default notification. */
    public static void sendDefault(Context context, int id, String title, String body) {
        send(context, id, title, body, CHANNEL_DEFAULT, Notification.PRIORITY_DEFAULT, false, null);
    }

    /** Post a high-priority / heads-up notification, likely to be promoted to Hyper Island. */
    public static void sendHigh(Context context, int id, String title, String body) {
        send(context, id, title, body, CHANNEL_HIGH, Notification.PRIORITY_HIGH, false, null);
    }

    /** Post a critical alert that bypasses DnD. */
    public static void sendCritical(Context context, int id, String title, String body) {
        send(context, id, title, body, CHANNEL_CRITICAL, Notification.PRIORITY_HIGH, true, new long[]{0, 500, 200, 500});
    }

    /** Post an ongoing (non-dismissable) notification - useful to simulate a Hyper Island "live" pill. */
    public static void sendOngoing(Context context, int id, String title, String body) {
        NotificationCompat.Builder b = base(context, title, body, CHANNEL_ISLAND, Notification.PRIORITY_HIGH);
        b.setOngoing(true);
        b.setOnlyAlertOnce(true);
        b.setCategory(NotificationCompat.CATEGORY_STATUS);
        notify(context, id, b);
    }

    /** Post a long-content (big text) notification. */
    public static void sendBigText(Context context, int id, String title, String body, String bigText) {
        NotificationCompat.Builder b = base(context, title, body, CHANNEL_HIGH, Notification.PRIORITY_HIGH);
        b.setStyle(new NotificationCompat.BigTextStyle().bigText(bigText).setSummaryText("Tap to expand"));
        notify(context, id, b);
    }

    /** Post a notification with action buttons (interactive). */
    public static void sendWithActions(Context context, int id, String title, String body) {
        NotificationCompat.Builder b = base(context, title, body, CHANNEL_ISLAND, Notification.PRIORITY_HIGH);

        Intent accept = new Intent(context, NotificationActionReceiver.class)
                .setAction(NotificationActionReceiver.ACTION_ACCEPT)
                .putExtra("id", id);
        PendingIntent acceptPi = PendingIntent.getBroadcast(context, id + 1, accept,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Intent dismiss = new Intent(context, NotificationActionReceiver.class)
                .setAction(NotificationActionReceiver.ACTION_DISMISS)
                .putExtra("id", id);
        PendingIntent dismissPi = PendingIntent.getBroadcast(context, id + 2, dismiss,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        b.addAction(0, "Accept", acceptPi);
        b.addAction(0, "Dismiss", dismissPi);
        notify(context, id, b);
    }

    /**
     * Post a dynamic live notification with a self-advancing progress bar —
     * the style suited to an island "live activity" pill. Updates every 500ms.
     */
    public static void sendProgress(final Context context, final int id, final String title) {
        if (!hasPermission(context)) return;

        final android.os.Handler handler = new android.os.Handler(context.getMainLooper());
        final int[] progress = {0};

        Runnable tick = new Runnable() {
            @Override
            public void run() {
                if (!hasPermission(context)) return;
                NotificationCompat.Builder b = base(context, title,
                        "Progress " + progress[0] + "%", CHANNEL_ISLAND, Notification.PRIORITY_HIGH);
                b.setProgress(100, progress[0], false)
                 .setOngoing(true)
                 .setOnlyAlertOnce(true);
                NotificationManagerCompat.from(context).notify(id, b.build());

                progress[0] += 10;
                if (progress[0] <= 100) {
                    handler.postDelayed(this, 500);
                } else {
                    NotificationCompat.Builder done = base(context, title,
                            "Complete", CHANNEL_ISLAND, Notification.PRIORITY_DEFAULT);
                    done.setProgress(0, 0, false).setAutoCancel(true);
                    if (hasPermission(context)) {
                        NotificationManagerCompat.from(context).notify(id, done.build());
                    }
                }
            }
        };
        handler.post(tick);
    }

    /** Cancel a specific notification. */
    public static void cancel(Context context, int id) {
        NotificationManagerCompat.from(context).cancel(id);
    }

    /** Cancel all notifications posted by this app. */
    public static void cancelAll(Context context) {
        NotificationManagerCompat.from(context).cancelAll();
    }

    // ---- internal helpers ----

    private static void send(Context context, int id, String title, String body,
                             String channel, int priority, boolean interrupt, long[] vibrate) {
        NotificationCompat.Builder b = base(context, title, body, channel, priority);
        if (interrupt) {
            b.setCategory(NotificationCompat.CATEGORY_ALARM)
             .setFullScreenIntent(appIntent(context), true)
             .setAutoCancel(true);
        }
        if (vibrate != null) b.setVibrate(vibrate);
        notify(context, id, b);
    }

    private static NotificationCompat.Builder base(Context context, String title, String body,
                                                   String channel, int priority) {
        NotificationCompat.Builder b = new NotificationCompat.Builder(context, channel)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(priority)
                .setAutoCancel(true)
                .setColor(NOTIFICATION_COLORS[0])
                .setContentIntent(appIntent(context));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            b.setColorized(true);
        }
        return b;
    }

    private static PendingIntent appIntent(Context context) {
        Intent i = new Intent(context, MainActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return PendingIntent.getActivity(context, 0, i,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    private static void notify(Context context, int id, NotificationCompat.Builder b) {
        if (hasPermission(context)) {
            NotificationManagerCompat.from(context).notify(id, b.build());
        }
    }
}