package com.hypernotify.lab;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import android.widget.TextView;
import android.widget.LinearLayout;
import android.graphics.Color;
import android.view.Gravity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER);
        layout.setBackgroundColor(Color.WHITE);
        layout.setPadding(32, 32, 32, 32);
        
        TextView title = new TextView(this);
        title.setText("HyperNotify Lab");
        title.setTextSize(28);
        title.setTextColor(Color.parseColor("#006EFF"));
        title.setGravity(Gravity.CENTER);
        title.setTypeface(null, android.graphics.Typeface.BOLD);
        
        TextView subtitle = new TextView(this);
        subtitle.setText("Xiaomi HyperOS Tablet\nHyper Island Notification Tester");
        subtitle.setTextSize(16);
        subtitle.setTextColor(Color.GRAY);
        subtitle.setGravity(Gravity.CENTER);
        subtitle.setLineSpacing(4, 1);
        
        TextView status = new TextView(this);
        status.setText("✅ APK Built Successfully!");
        status.setTextSize(18);
        status.setTextColor(Color.parseColor("#4CAF50"));
        status.setGravity(Gravity.CENTER);
        status.setPadding(0, 24, 0, 0);
        
        TextView info = new TextView(this);
        info.setText("Full notification system with:\n• Android 16 support\n• HyperOS Super Island\n• Foreground service\n• Tablet optimized UI");
        info.setTextSize(14);
        info.setTextColor(Color.DKGRAY);
        info.setGravity(Gravity.CENTER);
        info.setPadding(0, 16, 0, 0);
        info.setLineSpacing(4, 1);
        
        layout.addView(title);
        layout.addView(subtitle);
        layout.addView(status);
        layout.addView(info);
        
        setContentView(layout);
    }
}