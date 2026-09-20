// HyperNotify Lab - Minimal Android App
// Direct Android Gradle build

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
        
        TextView title = new TextView(this);
        title.setText("HyperNotify Lab");
        title.setTextSize(24);
        title.setTextColor(Color.parseColor("#006EFF"));
        title.setGravity(Gravity.CENTER);
        
        TextView subtitle = new TextView(this);
        subtitle.setText("Xiaomi HyperOS Tablet Hyper Island Notification Tester");
        subtitle.setTextSize(16);
        subtitle.setTextColor(Color.GRAY);
        subtitle.setGravity(Gravity.CENTER);
        
        TextView status = new TextView(this);
        status.setText("Android Gradle Build Successful!");
        status.setTextSize(18);
        status.setTextColor(Color.GREEN);
        status.setGravity(Gravity.CENTER);
        
        layout.addView(title);
        layout.addView(subtitle);
        layout.addView(status);
        
        setContentView(layout);
    }
}