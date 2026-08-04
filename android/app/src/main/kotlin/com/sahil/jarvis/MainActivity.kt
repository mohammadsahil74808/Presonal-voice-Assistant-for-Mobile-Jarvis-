package com.sahil.jarvis

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.sahil.jarvis/overlay"
    private var overlayWindow: JarvisOverlayWindow? = null
    private var methodChannel: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        overlayWindow = JarvisOverlayWindow(context.applicationContext ?: context).apply {
            onOverlayTapped = {
                try {
                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    }
                    startActivity(intent)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkOverlayPermission" -> {
                        val isGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(context)
                        } else {
                            true
                        }
                        result.success(isGranted)
                    }

                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            ).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    }

                    "openDefaultAssistantSettings" -> {
                        try {
                            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                Intent(Settings.ACTION_VOICE_INPUT_SETTINGS).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                            } else {
                                Intent(Settings.ACTION_SETTINGS).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        }
                    }

                    "startForegroundService" -> {
                        JarvisForegroundService.startService(context)
                        result.success(true)
                    }

                    "stopForegroundService" -> {
                        JarvisForegroundService.stopService(context)
                        result.success(true)
                    }

                    "pauseWakeWord" -> {
                        JarvisForegroundService.pauseWakeWord(context)
                        result.success(true)
                    }

                    "resumeWakeWord" -> {
                        JarvisForegroundService.resumeWakeWord(context)
                        result.success(true)
                    }

                    "showOverlayWindow" -> {
                        overlayWindow?.showOverlay()
                        result.success(true)
                    }

                    "updateOverlayState" -> {
                        val state = call.argument<String>("state") ?: "idle"
                        val previewText = call.argument<String>("previewText") ?: ""
                        overlayWindow?.updateState(state, previewText)
                        result.success(true)
                    }

                    "updateAudioAmplitude" -> {
                        val amp = call.argument<Double>("amplitude")?.toFloat() ?: 0f
                        overlayWindow?.updateAudioAmplitude(amp)
                        result.success(true)
                    }

                    "hideOverlayWindow" -> {
                        overlayWindow?.hideOverlay()
                        result.success(true)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }

        mainHandler.post {
            handleAssistantIntent(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        mainHandler.post {
            handleAssistantIntent(intent)
        }
    }

    private fun handleAssistantIntent(intent: Intent?) {
        val isTrigger = intent?.getBooleanExtra("trigger_overlay", false) == true ||
                intent?.getBooleanExtra("wake_word_triggered", false) == true ||
                intent?.getBooleanExtra("assistant_triggered", false) == true ||
                intent?.action == Intent.ACTION_ASSIST ||
                intent?.action == Intent.ACTION_VOICE_COMMAND

        if (isTrigger) {
            try {
                if (overlayWindow?.isOverlayPermissionGranted() == true) {
                    overlayWindow?.showOverlay()
                    overlayWindow?.updateState("listening", "◉ Listening... Speak, Sir")
                    methodChannel?.invokeMethod("onAssistantTriggered", null)
                    moveTaskToBack(true)
                } else {
                    methodChannel?.invokeMethod("onAssistantTriggered", null)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
