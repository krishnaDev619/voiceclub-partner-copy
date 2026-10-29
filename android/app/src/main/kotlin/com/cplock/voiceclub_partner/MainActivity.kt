package com.cplock.voiceclub_partner

import android.content.Intent
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessaging
import com.singular.flutter_sdk.SingularBridge
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterFragmentActivity() {
    private val FOREGROUNDSERVICECHANNEL = "foregroundChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        FirebaseMessaging.getInstance().token
            .addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    return@addOnCompleteListener
                }
                val token: String? = task.result
                // Use or store the token
            }

        // Microphone Foreground Service
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FOREGROUNDSERVICECHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startService") {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val intent = Intent(this, RTCForegroundService::class.java)
                        startForegroundService(intent)
                        result.success(null)
                    }
                } else if (call.method == "stopService") {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val intent = Intent(this, RTCForegroundService::class.java)
                        stopService(intent)
                        result.success(null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rtcCallEndService")
            .setMethodCallHandler { call, result ->
                if (call.method == "setCallConfig") {
                    val inCall = call.argument<Boolean>("inCall") != null && call.argument<Boolean>("inCall") == true

                    val channelId = call.argument<String>("channel_id")

                    val endedBy = call.argument<Int>("ended_by") ?: 0

                    val jwtToken = call.argument<String>("jwt_token")
                    val endCallUrl = call.argument<String>("end_call_url")
                    val callAlreadyEnded = call.argument<Boolean>("call_already_ended") != null
                            && call.argument<Boolean>("call_already_ended") == true

                    val editor = getSharedPreferences("RTC_PREFS", MODE_PRIVATE).edit()
                    editor.putString("channel_id", channelId)
                    editor.putInt("ended_by", endedBy)
                    editor.putString("jwt_token", jwtToken)
                    editor.putString("end_call_url", endCallUrl)
                    editor.putBoolean("call_already_ended", callAlreadyEnded)
                    editor.apply()

                    val intent = Intent(this, RTCKeepAliveService::class.java)
                    if (inCall) {
                        startService(intent)
                    } else {
                        Log.d("MainActivity", "RTCKeepAliveService stopped")
                        stopService(intent)
                    }
                    result.success(null)
                } else if (call.method == "setCallAlreadyEnded") {
                    getSharedPreferences("RTC_PREFS", MODE_PRIVATE).edit()
                        .putBoolean("call_already_ended", true)
                        .apply()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        flutterEngine?.activityControlSurface?.onNewIntent(intent)
        if (intent.data != null) {           
            SingularBridge.onNewIntent(intent)
        }
    }
}