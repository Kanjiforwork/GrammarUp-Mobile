package com.example.grammar_up

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var profileHandler: ProfileMethodChannelHandler
    private lateinit var notificationHandler: NotificationMethodChannelHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize and register profile method channel
        profileHandler = ProfileMethodChannelHandler(applicationContext)
        profileHandler.registerChannel(flutterEngine.dartExecutor.binaryMessenger)
        
        // Initialize and register notification method channel
        notificationHandler = NotificationMethodChannelHandler(applicationContext, flutterEngine)
    }
}
