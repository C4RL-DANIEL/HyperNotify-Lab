package com.hypernotify.lab;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import androidx.core.app.NotificationManagerCompat;

/**
 * Handles presses on notification action buttons.
 */
public class NotificationActionReceiver extends BroadcastReceiver {

    public static final String ACTION_ACCEPT = "com.hypernotify.lab.ACCEPT";
    public static final String ACTION_DISMISS = "com.hypernotify.lab.DISMISS";

    @Override
    public void onReceive(Context context, Intent intent) {
        int id = intent.getIntExtra("id", -1);
        String action = intent.getAction();

        if (ACTION_DISMISS.equals(action)) {
            NotificationManagerCompat.from(context).cancel(id);
        } else if (ACTION_ACCEPT.equals(action)) {
            // Toast won't show from a background receiver on newer Android; safe no-op here.
            NotificationManagerCompat.from(context).cancel(id);
        }
    }
}