package com.sahil.jarvis

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.service.voice.VoiceInteractionSession

class JarvisVoiceInteractionSession(context: Context) : VoiceInteractionSession(context) {

    private val overlayWindow = JarvisOverlayWindow(context)

    override fun onShow(args: Bundle?, showFlags: Int) {
        super.onShow(args, showFlags)
        
        // Show ONLY compact bottom translucent JARVIS floating overlay UI (Siri / Google Assistant style)
        // DO NOT open full app screen
        overlayWindow.showOverlay()
        overlayWindow.updateState("listening", "Listening for your voice...")

        val triggerIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("trigger_overlay", true)
            putExtra("assistant_triggered", true)
        }
        context.startActivity(triggerIntent)
    }

    override fun onHide() {
        super.onHide()
        overlayWindow.hideOverlay()
    }
}
