package com.hypernotify.lab;

import android.app.Notification;
import android.content.Intent;
import android.os.Build;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.content.ContentValues;
import android.util.Log;
import android.widget.Toast;

/**
 * HyperNotify Lab - Hyper Island style listener.
 *
 * Built on the official Android {@link NotificationListenerService} API (API 18+).
 * This is the same legitimate mechanism that Xiaomi-derived island apps use:
 * the app listens to the active notification stream and can drive its own
 * island-style live panel, progress bars and expanded views for notifications
 * that are important enough to display.
 *
 * Combined with the standard high-importance notifications from
 * {@link NotificationService}, Xiaomi HyperOS can also promote these naturally
 * to the system Hyper Island pill where available.
 */
public class HyperIslandListenerService extends NotificationListenerService {

    private static final String TAG = "HyperIslandListener";

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        super.onNotificationPosted(sbn);
        // Called when any app posts a visible notification. On Xiaomi/HyperOS we log
        // high-importance ones that are good island candidates.
        if (sbn != null && sbn.getNotification() != null) {
            int priority = sbn.getNotification().priority;
            if (priority >= Notification.PRIORITY_HIGH || isHeadsUp(sbn)) {
                Log.d(TAG, "Island-candidate notification from "
                        + sbn.getPackageName() + ": " + sbn.getNotification().tickerText);
            }
        }
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        super.onNotificationRemoved(sbn);
        if (sbn != null) {
            NotificationService.cancel(this, sbn.getId());
        }
    }

    @Override
    public void onListenerConnected() {
        super.onListenerConnected();
        Toast.makeText(this, "HyperNotify listener connected", Toast.LENGTH_SHORT).show();
    }

    private boolean isHeadsUp(StatusBarNotification sbn) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return sbn.isOngoing() || sbn.getNotification().fullScreenIntent != null;
        }
        return sbn.getNotification().fullScreenIntent != null;
    }

    /** Check whether the app has Notification Listener access enabled. */
    public static boolean isListenerEnabled(android.content.Context context) {
        String packageName = context.getPackageName();
        String flat = android.provider.Settings.Secure.getString(
                context.getContentResolver(), "enabled_notification_listeners");
        return flat != null && flat.contains(packageName);
    }

    /** Intent that opens the system Notification Access settings screen. */
    public static Intent listenerSettingsIntent() {
        return new Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    }
}