package com.example.grammar_up

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.grammar_up/native"
    private lateinit var profileHandler: ProfileMethodChannelHandler
    private lateinit var notificationHandler: NotificationMethodChannelHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize and register profile method channel
        profileHandler = ProfileMethodChannelHandler(applicationContext)
        profileHandler.registerChannel(flutterEngine.dartExecutor.binaryMessenger)

        // Initialize and register notification method channel
        notificationHandler = NotificationMethodChannelHandler(applicationContext, flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFeedback" -> {
                    val intent = Intent(this, FeedbackActivity::class.java)
                    startActivity(intent)
                    result.success(null)
                }
                "openAbout" -> {
                    val intent = Intent(this, AboutActivity::class.java)
                    startActivity(intent)
                    result.success(null)
                }
                "openAchievements" -> {
                    val userId = call.argument<String>("userId") ?: ""
                    val accessToken = call.argument<String>("accessToken") ?: ""
                    val isDarkMode = call.argument<Boolean>("isDarkMode") ?: false
                    val intent = Intent(this, AchievementActivity::class.java).apply {
                        putExtra("userId", userId)
                        putExtra("accessToken", accessToken)
                        putExtra("isDarkMode", isDarkMode)
                    }
                    startActivity(intent)
                    result.success(null)
                }
                "openEditProfile" -> {
                    val userId = call.argument<String>("userId") ?: ""
                    val accessToken = call.argument<String>("accessToken") ?: ""
                    val isDarkMode = call.argument<Boolean>("isDarkMode") ?: false
                    val intent = Intent(this, EditProfileActivity::class.java).apply {
                        putExtra("userId", userId)
                        putExtra("accessToken", accessToken)
                        putExtra("isDarkMode", isDarkMode)
                    }
                    startActivity(intent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
