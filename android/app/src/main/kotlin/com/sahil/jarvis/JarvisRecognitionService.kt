package com.sahil.jarvis

import android.content.Intent
import android.speech.RecognitionService

class JarvisRecognitionService : RecognitionService() {
    override fun onStartListening(intent: Intent?, listener: Callback?) {
        // Android VoiceRecognition callback binder for Assistant Role
    }

    override fun onCancel(listener: Callback?) {
    }

    override fun onStopListening(listener: Callback?) {
    }
}
