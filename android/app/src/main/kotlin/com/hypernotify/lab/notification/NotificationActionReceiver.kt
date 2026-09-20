package com.hypernotify.lab.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class NotificationActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_PREFIX = "com.hypernotify.lab.NOTIFICATION_ACTION_"
        private const val TAG = "NotificationActionRcvr"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val notificationId = intent.getIntExtra("notification_id", -1)
        val payload = intent.getStringExtra("payload") ?: ""
        
        Log.d(TAG, "Received action: $action for notification: $notificationId")

        when {
            action.endsWith("_DISMISS") -> {
                dismissNotification(context, notificationId)
            }
            action.endsWith("_OPEN") -> {
                openApp(context, payload)
            }
            action.endsWith("_REPLY") -> {
                handleReply(context, intent)
            }
            else -> {
                // Custom action - broadcast to Flutter
                broadcastToFlutter(context, action, notificationId, payload)
            }
        }
    }

    private fun dismissNotification(context: Context, notificationId: Int) {
        val manager = NotificationManagerCompat.from(context)
        manager.cancel(notificationId)
    }

    private fun openApp(context: Context, payload: String) {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("payload", payload)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        context.startActivity(intent)
    }

    private fun handleReply(context: Context, intent: Intent) {
        val remoteInput = android.app.RemoteInput.getResultsFromIntent(intent)
        val replyText = remoteInput?.getCharSequence("reply_key")?.toString() ?: ""
        
        // Broadcast reply to Flutter
        val flutterIntent = Intent("com.hypernotify.lab.NOTIFICATION_REPLY").apply {
            putExtra("notification_id", intent.getIntExtra("notification_id", -1))
            putExtra("reply_text", replyText)
            putExtra("payload", intent.getStringExtra("payload") ?: "")
        }
        context.sendBroadcast(flutterIntent)
    }

    private fun broadcastToFlutter(context: Context, action: String, notificationId: Int, payload: String) {
        val flutterIntent = Intent("com.hypernotify.lab.NOTIFICATION_ACTION").apply {
            putExtra("action", action)
            putExtra("notification_id", notificationId)
            putExtra("payload", payload)
        }
        context.sendBroadcast(flutterIntent)
    }
}