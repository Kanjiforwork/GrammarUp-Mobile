package com.example.grammar_up

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

class NotificationMethodChannelHandler(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.example.grammar_up/notifications"
        private const val NOTIFICATION_CHANNEL_ID = "grammar_up_notifications"
        private const val NOTIFICATION_CHANNEL_NAME = "Grammar Up Notifications"
        private const val PREFS_NAME = "notification_preferences"
        private const val PREF_KEY_ENABLED = "notifications_enabled"
    }

    private val channel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL_NAME
    )
    
    private val sharedPreferences: SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private val notificationManager: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    init {
        channel.setMethodCallHandler(this)
        createNotificationChannel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "requestPermission" -> requestPermission(result)
            "isNotificationEnabled" -> isNotificationEnabled(result)
            "setNotificationEnabled" -> setNotificationEnabled(call, result)
            "showLocalNotification" -> showLocalNotification(call, result)
            "getFCMToken" -> getFCMToken(result)
            "subscribeToTopic" -> subscribeToTopic(call, result)
            "unsubscribeFromTopic" -> unsubscribeFromTopic(call, result)
            else -> result.notImplemented()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                NOTIFICATION_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for Grammar Up app"
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun initialize(result: MethodChannel.Result) {
        try {
            createNotificationChannel()
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize notifications: ${e.message}", null)
        }
    }

    private fun requestPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val hasPermission = ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED
                
                result.success(hasPermission)
            } else {
                // For Android < 13, notification permission is granted by default
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("PERMISSION_ERROR", "Failed to check permission: ${e.message}", null)
        }
    }

    private fun isNotificationEnabled(result: MethodChannel.Result) {
        try {
            val enabled = sharedPreferences.getBoolean(PREF_KEY_ENABLED, true)
            result.success(enabled)
        } catch (e: Exception) {
            result.error("PREFS_ERROR", "Failed to get notification preference: ${e.message}", null)
        }
    }

    private fun setNotificationEnabled(call: MethodCall, result: MethodChannel.Result) {
        try {
            val enabled = call.argument<Boolean>("enabled") ?: true
            sharedPreferences.edit().putBoolean(PREF_KEY_ENABLED, enabled).apply()
            result.success(true)
        } catch (e: Exception) {
            result.error("PREFS_ERROR", "Failed to save notification preference: ${e.message}", null)
        }
    }

    private fun showLocalNotification(call: MethodCall, result: MethodChannel.Result) {
        try {
            // Check if notifications are enabled
            val enabled = sharedPreferences.getBoolean(PREF_KEY_ENABLED, true)
            if (!enabled) {
                result.success(false)
                return
            }

            // Check notification permission for Android 13+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    result.error("NO_PERMISSION", "Notification permission not granted", null)
                    return
                }
            }

            val title = call.argument<String>("title") ?: "Grammar Up"
            val body = call.argument<String>("body") ?: ""
            // Handle id as Number (can be Int or Long from Flutter) and convert to Int
            val id = (call.argument<Number>("id")?.toInt()) ?: (System.currentTimeMillis() % Int.MAX_VALUE).toInt()

            // Create intent for notification tap
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            val notification = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build()

            NotificationManagerCompat.from(context).notify(id, notification)
            result.success(true)
        } catch (e: Exception) {
            result.error("NOTIFICATION_ERROR", "Failed to show notification: ${e.message}", null)
        }
    }

    private fun getFCMToken(result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val token = FirebaseMessaging.getInstance().token.await()
                withContext(Dispatchers.Main) {
                    result.success(token)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("FCM_TOKEN_ERROR", "Failed to get FCM token: ${e.message}", null)
                }
            }
        }
    }

    private fun subscribeToTopic(call: MethodCall, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val topic = call.argument<String>("topic") 
                    ?: throw IllegalArgumentException("Topic is required")
                
                FirebaseMessaging.getInstance().subscribeToTopic(topic).await()
                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TOPIC_ERROR", "Failed to subscribe to topic: ${e.message}", null)
                }
            }
        }
    }

    private fun unsubscribeFromTopic(call: MethodCall, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val topic = call.argument<String>("topic") 
                    ?: throw IllegalArgumentException("Topic is required")
                
                FirebaseMessaging.getInstance().unsubscribeFromTopic(topic).await()
                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TOPIC_ERROR", "Failed to unsubscribe from topic: ${e.message}", null)
                }
            }
        }
    }
}
