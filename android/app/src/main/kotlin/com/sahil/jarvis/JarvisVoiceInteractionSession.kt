package com.sahil.jarvis

import android.content.Context
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
    }

    override fun onHide() {
        super.onHide()
        overlayWindow.hideOverlay()
    }
}
