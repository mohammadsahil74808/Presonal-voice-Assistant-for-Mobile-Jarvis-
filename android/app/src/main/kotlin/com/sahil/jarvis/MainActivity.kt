package com.sahil.jarvis

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.sahil.jarvis/overlay"
    private var overlayWindow: JarvisOverlayWindow? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        overlayWindow = JarvisOverlayWindow(context).apply {
            onOverlayTapped = {
                // Open main app when overlay is tapped
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                startActivity(intent)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
}
