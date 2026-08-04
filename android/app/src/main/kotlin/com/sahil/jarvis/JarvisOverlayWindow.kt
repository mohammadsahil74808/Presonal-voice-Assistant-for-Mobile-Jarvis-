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
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView

class JarvisOverlayWindow(private val context: Context) {

    private val windowManager: WindowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private var overlayView: View? = null
    private var statusTextView: TextView? = null
    private var orbView: View? = null
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
                val layoutParams = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
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
                    y = 120 // Positioned gracefully above Android gesture navigation bar
                }

                val container = LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    gravity = Gravity.CENTER
                    setPadding(36, 24, 36, 24)

                    // Rounded translucent futuristic dark JARVIS card background
                    background = GradientDrawable().apply {
                        setColor(Color.parseColor("#EE0B0E14")) // Dark translucent cyan-navy
                        cornerRadius = 48f
                        setStroke(2, Color.parseColor("#4400E5FF")) // Subtle cyan border glow
                    }

                    setOnClickListener {
                        onOverlayTapped?.invoke()
                    }
                }

                // Inner Orb View
                val orb = View(context).apply {
                    val orbParams = LinearLayout.LayoutParams(64, 64).apply {
                        bottomMargin = 12
                    }
                    this.layoutParams = orbParams
                    background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF00E5FF")) // JARVIS Cyan Core
                        setStroke(6, Color.parseColor("#8800B0FF"))
                    }
                }
                orbView = orb
                container.addView(orb)

                // Status Label
                val statusText = TextView(context).apply {
                    text = "JARVIS • Listening..."
                    setTextColor(Color.parseColor("#EEF4F8"))
                    textSize = 14f
                    gravity = Gravity.CENTER
                }
                statusTextView = statusText
                container.addView(statusText)

                overlayView = container
                windowManager.addView(container, layoutParams)
                isShowing = true
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
                "listening" -> "◉ Listening..."
                "processing" -> "⚡ Thinking..."
                "speaking" -> if (previewText.isNotEmpty()) previewText else "💬 Speaking..."
                "error" -> "⚠️ $previewText"
                else -> "JARVIS Active"
            }
            statusTextView?.text = displayMsg

            when (state.lowercase()) {
                "listening" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF00E5FF")) // Bright Cyan
                        setStroke(8, Color.parseColor("#8800E5FF"))
                    }
                }
                "processing" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FFFFAB00")) // Gold Amber
                        setStroke(8, Color.parseColor("#88FFD600"))
                    }
                }
                "speaking" -> {
                    orbView?.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#FF00E676")) // Emerald Green
                        setStroke(8, Color.parseColor("#8800C853"))
                    }
                }
            }
        }
    }

    fun hideOverlay() {
        mainHandler.post {
            try {
                pulseAnimator?.cancel()
                if (isShowing && overlayView != null) {
                    windowManager.removeView(overlayView)
                    overlayView = null
                    isShowing = false
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun startOrbPulse() {
        orbView?.let { view ->
            pulseAnimator = ObjectAnimator.ofFloat(view, "scaleX", 1.0f, 1.15f, 1.0f).apply {
                duration = 1200
                repeatCount = ValueAnimator.INFINITE
                start()
            }
        }
    }
}
