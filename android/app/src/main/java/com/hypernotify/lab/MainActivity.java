package com.hypernotify.lab;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.annotation.NonNull;

/**
 * HyperNotify Lab - HyperOS Hyper Island notification extension.
 *
 * A real, interactive notification tester. Requests notification permission,
 * creates all channels (so HyperOS can promote to Hyper Island) and lets you
 * send several kinds of notifications built on the standard Android 16 APIs.
 */
public class MainActivity extends Activity {

    private TextView statusView;
    private int counter = 1000;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        NotificationService.createChannels(this);

        // ----- UI build -----
        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER_HORIZONTAL);
        root.setPadding(32, 48, 32, 48);
        scroll.addView(root);

        // Title
        TextView title = new TextView(this);
        title.setText("HyperNotify Lab");
        title.setTextSize(28);
        title.setTextColor(0xFF006EFF);
        title.setGravity(Gravity.CENTER);
        title.setTypeface(null, android.graphics.Typeface.BOLD);
        root.addView(title);

        // Subtitle
        TextView sub = new TextView(this);
        sub.setText("Xiaomi HyperOS Hyper Island\nnotification extension (Android 16 APIs)");
        sub.setTextSize(15);
        sub.setTextColor(Color.GRAY);
        sub.setGravity(Gravity.CENTER);
        sub.setLineSpacing(4, 1);
        sub.setPadding(0, 8, 0, 24);
        root.addView(sub);

        // Status panel
        statusView = new TextView(this);
        statusView.setTextSize(13);
        statusView.setTextColor(Color.DKGRAY);
        statusView.setGravity(Gravity.CENTER);
        statusView.setPadding(16, 16, 16, 16);
        root.addView(statusView);

        // Buttons
        root.addView(bigButton("Allow Notifications", c -> requestNotificationPermission()));
        root.addView(bigButton("Enable Island Listener Access", c -> requestListenerAccess()));
        root.addView(bigButton("Send Default Notification", c -> NotificationService.sendDefault(this, counter++, "Default", "A standard notification")));
        root.addView(bigButton("Send High / Heads-Up (Island)", c -> NotificationService.sendHigh(this, counter++, "Hyper Island", "Heads-up notification for Hyper Island")));
        root.addView(bigButton("Send Critical Alert", c -> NotificationService.sendCritical(this, counter++, "Critical", "Critical alert that bypasses DnD")));
        root.addView(bigButton("Send Ongoing (Pill-Style)", c -> NotificationService.sendOngoing(this, counter++, "Live Activity", "Ongoing pillar-style notification")));
        root.addView(bigButton("Send Live Progress", c -> NotificationService.sendProgress(this, counter++, "Download")));
        root.addView(bigButton("Send Big Text", c -> NotificationService.sendBigText(this, counter++, "Expanded", "Tap to see more", Lorem.LONG)));
        root.addView(bigButton("Send with Actions", c -> NotificationService.sendWithActions(this, counter++, "Interactive", "Notification with action buttons")));
        root.addView(bigButton("Clear All", c -> NotificationService.cancelAll(this)));

        setContentView(scroll);
        refreshStatus();
    }

    private void requestListenerAccess() {
        startActivity(HyperIslandListenerService.listenerSettingsIntent());
    }

    private Button bigButton(String text, ClickHandler h) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextSize(15);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMargins(0, 12, 0, 0);
        b.setLayoutParams(lp);
        b.setOnClickListener(v -> h.onClick());
        return b;
    }

    @FunctionalInterface
    private interface ClickHandler { void onClick(); }

    @Override
    protected void onResume() {
        super.onResume();
        refreshStatus();
    }

    private void refreshStatus() {
        boolean perm = NotificationService.hasPermission(this);
        boolean xiaomi = HyperOSUtils.isXiaomiDevice();
        boolean hyperos = HyperOSUtils.isHyperOS(this);
        boolean channelEnabled = NotificationService.defaultChannelEnabled(this);
        boolean listener = HyperIslandListenerService.isListenerEnabled(this);

        String text = HyperOSUtils.deviceSummary()
                + "\nNotification permission: " + (perm ? "GRANTED" : "DENIED")
                + "\nListener access: " + (listener ? "ON" : "OFF (tap to enable)")
                + "\nHyper Island auto-enable: " + xiaomi
                + "\nHyperOS (Xiaomi + API 34+): " + hyperos
                + "\nChannel enabled: " + (channelEnabled ? "YES" : "NO");
        statusView.setText(text);
    }

    private void requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= 33
                && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 1);
        } else {
            startActivity(NotificationService.permissionIntent(this));
        }
    }

    @Override
    public void onRequestPermissionsResult(int req, @NonNull String[] perms, @NonNull int[] results) {
        super.onRequestPermissionsResult(req, perms, results);
        refreshStatus();
    }

    /** Static long text for the big-text demo. */
    static final class Lorem {
        static final String LONG =
            "HyperNotify Lab demonstrates the Android 16 notification APIs used "
          + "by Xiaomi HyperOS. When notifications are sent at high importance with "
          + "sound and heads-up behavior, HyperOS can promote them to the Hyper "
          + "Island pill at the top of the screen. On supported Xiaomi tablets you "
          + "can watch notifications collapse into a small interactive island that "
          + "expands on tap. This long-content style makes the expanded view useful "
          + "for richer details like live scores, timers or messages.";
    }
}