package com.sahil.jarvis

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.OvershootInterpolator
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class JarvisOverlayWindow(private val context: Context) {

    private val windowManager: WindowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private var overlayView: View? = null
    private var statusTextView: TextView? = null
    private var orbView: View? = null
    private var containerView: LinearLayout? = null
    private var isShowing = false
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pulseAnimator: ObjectAnimator? = null

    var onOverlayTapped: (() -> Unit)? = null
    var onCancelTapped: (() -> Unit)? = null

    fun isOverlayPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            android.provider.Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    fun showOverlay() {
        if (!isOverlayPermissionGranted()) return
        if (isShowing && overlayView != null) return

        mainHandler.post {
            try {
                // Compact floating capsule window params (WRAP_CONTENT width, NOT MATCH_PARENT!)
                val layoutParams = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    } else {
                        @Suppress("DEPRECATION")
                        WindowManager.LayoutParams.TYPE_PHONE
                    },
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                    y = 140 // Floating gracefully above Android gesture bar
                }

                // Siri-Style Horizontal Glass Capsule Container
                val container = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(40, 20, 40, 20)

                    background = GradientDrawable().apply {
                        setColor(Color.parseColor("#F0070A12")) // Dark glass capsule backdrop
                        cornerRadius = 80f
                        setStroke(4, Color.parseColor("#9900E5FF")) // Glowing neon cyan border
                    }

                    elevation = 20f

                    // Entrance spring animation
                    alpha = 0f
                    scaleX = 0.65f
                    scaleY = 0.65f

                    setOnClickListener {
                        onOverlayTapped?.invoke()
                    }
                }
                containerView = container

                // Glowing Voice-Reactive Orb Dot (Left)
                val orb = View(context).apply {
                    val orbParams = LinearLayout.LayoutParams(36, 36).apply {
                        rightMargin = 20
                    }
                    this.layoutParams = orbParams
                    background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF00E5FF")) // JARVIS Cyan Core
                        setStroke(6, Color.parseColor("#AA00B0FF"))
                    }
                }
                orbView = orb
                container.addView(orb)

                // Text Layout Container (Center)
                val textLayout = LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    gravity = Gravity.CENTER_VERTICAL
                }

                // Subtitle Header
                val subtitleText = TextView(context).apply {
                    text = "MINI JARVIS HUD"
                    setTextColor(Color.parseColor("#FF00E5FF"))
                    textSize = 10f
                    letterSpacing = 0.15f
                    paint.isFakeBoldText = true
                }
                textLayout.addView(subtitleText)

                // Status Message Text
                val statusText = TextView(context).apply {
                    text = "◉ Listening... Speak, Sir"
                    setTextColor(Color.parseColor("#EEF4F8"))
                    textSize = 13.5f
                    maxLines = 2
                    ellipsize = TextUtils.TruncateAt.END
                }
                statusTextView = statusText
                textLayout.addView(statusText)

                container.addView(textLayout)

                // Dismiss Button (Right)
                val closeButton = TextView(context).apply {
                    val btnParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        leftMargin = 24
                    }
                    this.layoutParams = btnParams
                    text = " ✕ "
                    setTextColor(Color.parseColor("#88A0C0"))
                    textSize = 14f
                    setOnClickListener {
                        hideOverlay()
                        onCancelTapped?.invoke()
                    }
                }
                container.addView(closeButton)

                overlayView = container
                windowManager.addView(container, layoutParams)
                isShowing = true

                // Entrance spring transition (~260ms)
                container.animate()
                    .alpha(1f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(260)
                    .setInterpolator(OvershootInterpolator(1.15f))
                    .start()

                startOrbPulse()

            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun updateState(state: String, previewText: String = "") {
        mainHandler.post {
            if (!isShowing) return@post
            val displayMsg = when (state.lowercase()) {
                "listening" -> if (previewText.isNotEmpty()) previewText else "◉ Listening... Speak, Sir"
                "processing" -> "⚡ Thinking..."
                "speaking" -> if (previewText.isNotEmpty()) previewText else "💬 JARVIS Speaking..."
                "error" -> "⚠️ $previewText"
                else -> "JARVIS Active"
            }
            statusTextView?.text = displayMsg

            when (state.lowercase()) {
                "listening" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF00E5FF")) // Cyan
                        setStroke(8, Color.parseColor("#AA00E5FF"))
                    }
                    containerView?.background = GradientDrawable().apply {
                        setColor(Color.parseColor("#F0070A12"))
                        cornerRadius = 80f
                        setStroke(4, Color.parseColor("#9900E5FF"))
                    }
                }
                "processing" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FFFFAB00")) // Gold Amber
                        setStroke(8, Color.parseColor("#AAFFD600"))
                    }
                    containerView?.background = GradientDrawable().apply {
                        setColor(Color.parseColor("#F0070A12"))
                        cornerRadius = 80f
                        setStroke(4, Color.parseColor("#99FFAB00"))
                    }
                }
                "speaking" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF0077FF")) // Vibrant Blue
                        setStroke(8, Color.parseColor("#AA00E676"))
                    }
                    containerView?.background = GradientDrawable().apply {
                        setColor(Color.parseColor("#F0070A12"))
                        cornerRadius = 80f
                        setStroke(4, Color.parseColor("#990077FF"))
                    }
                }
            }
        }
    }

    fun updateAudioAmplitude(amplitude: Float) {
        mainHandler.post {
            if (!isShowing || orbView == null) return@post
            val scale = 1.0f + (amplitude.coerceIn(0f, 1f) * 0.45f)
            orbView?.scaleX = scale
            orbView?.scaleY = scale
        }
    }

    fun hideOverlay() {
        mainHandler.post {
            try {
                pulseAnimator?.cancel()
                val viewToRemove = overlayView
                if (isShowing && viewToRemove != null) {
                    isShowing = false
                    overlayView = null
                    viewToRemove.animate()
                        .alpha(0f)
                        .scaleX(0.7f)
                        .scaleY(0.7f)
                        .setDuration(200)
                        .withEndAction {
                            try {
                                windowManager.removeView(viewToRemove)
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                        .start()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun startOrbPulse() {
        orbView?.let { view ->
            pulseAnimator = ObjectAnimator.ofFloat(view, "scaleX", 1.0f, 1.18f, 1.0f).apply {
                duration = 1000
                repeatCount = ValueAnimator.INFINITE
                start()
            }
        }
    }
}
