package com.sahil.jarvis

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.service.voice.VoiceInteractionSession
import android.view.View

class JarvisVoiceInteractionSession(context: Context) : VoiceInteractionSession(context) {

    private val overlayWindow = JarvisOverlayWindow(context)

    override fun onCreate() {
        super.onCreate()
    }

    override fun onShow(args: Bundle?, showFlags: Int) {
        super.onShow(args, showFlags)
        
        // Display native translucent JARVIS floating overlay over active app when invoked
        overlayWindow.showOverlay()
        overlayWindow.updateState("listening", "Listening for your voice...")

        // Launch main activity in background if needed
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("assistant_invocation", true)
        }
        context.startActivity(intent)
    }

    override fun onHide() {
        super.onHide()
        overlayWindow.hideOverlay()
    }
}
